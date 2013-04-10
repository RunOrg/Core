(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Core = MMail_core

module type PLUGIN = sig
  include Ohm.Fmt.FMT
  val id : IMail.Plugin.t
  val iid : t -> IInstance.t option 
  val uid : t -> IUser.t 
  val from : t -> IAvatar.t option     
  val solve : t -> IMail.Solve.t option 
  val item : t -> bool 
end

(* Marking solvable items as solved *) 

module SolveArgs = Fmt.Make(struct type json t = (IMail.Plugin.t * IMail.Solve.t) end)

module SolvableView = CouchDB.DocView(struct
  module Key = SolveArgs
  module Value = Fmt.Unit
  module Doc = Core.Data
  module Design = Core.Design
  let name = "solvable"
  let map = "if (!doc.dead && doc.solved !== null && doc.solved[0] === 'n') emit([doc.plugin,doc.solved[1]]);"
end)

let task_solve, def_solve = O.async # declare "notif-solve" SolveArgs.fmt
let solve key =
  let! now  = ohmctx (#time) in
  let! mids = ohm (SolvableView.doc_query ~startkey:key ~endkey:key ~endinclusive:true ~limit:5 ()) in
  if mids = [] then return () else
    let! () = ohm (Run.list_iter (#id |- IMail.of_id |- Core.solved) mids) in
    task_solve key 

let () = def_solve solve

(* Global parser and check management -- standard plugin pattern *) 

let checks  = ref []
let parsers = Hashtbl.create 100 

let add_parser pid parse = 
  Hashtbl.add parsers pid parse 

let add_check f = 
  checks := f :: !checks

let check () = 
  if !checks <> [] then begin 
    List.iter (fun f -> f ()) !checks ;
    checks := []
  end

let get_parser pid = 
  check () ;
  try Some (Hashtbl.find parsers pid) with Not_found -> None

let parse mid t = 
  let! parse = req_or (return None) (get_parser t.Core.Data.plugin) in
  parse mid t 

let parse_mail mid t = 
  let! render, info = ohm_req_or (return None) (parse mid t) in
  return (Some (object
    method info       = info 
    method act a      = render # act a
    method mail uid u = render # mail uid u 
  end))

let parse_item mid t = 
  let! render, info = ohm_req_or (return None) (parse mid t) in
  let! item = req_or (return None) (render # item) in
  return (Some (object
    method info  = info 
    method act a = render # act a
    method item  = item
  end))
  
(* Actual plugin registration *) 

module Register = functor(P:PLUGIN) -> struct

  type t = P.t

  (* Post-definition of render function requires some launch-time checks. *)

  let render = ref None 
  let () = add_check (fun () -> if !render = None then failwith 
      (Printf.sprintf "Mail plugin %s : no renderer defined" (IMail.Plugin.to_string P.id)))
    
  let define r = 
    render := Some r

  (* Register the parser for this plugin *)
      
  let parse mid m = 
    let! t = req_or (return None) (P.of_json_safe m.Core.Data.data) in
    let  render = match !render with None -> assert false | Some r -> r in
    let  info : MMail_types.info = Core.Data.(object
      method plugin  = P.id
      method id      = mid
      method wid     = m.wid
      method iid     = m.iid
      method uid     = m.uid
      method from    = P.from t 
      method time    = m.time
      method opened  = m.opened
      method clicked = m.clicked
      method sent    = m.sent
      method blocked = m.blocked
      method solved  = m.solved
      method accept  = m.accept
      method zapped  = m.zapped
    end) in 
    let! r = ohm_req_or (return None) (render t info) in
    return (Some (r, info))

  let () = add_parser P.id parse

  (* Sending one notification serves as base for sending many. *)

  let send_one ?time ?mwid t =

    let! time' = ohmctx (#time) in
    let  time  = Date.of_timestamp (BatOption.default time' time) in 

    let mwid = match mwid with Some mwid -> mwid | None -> IMail.Wave.gen () in
    
    let solved = BatOption.map (fun msid -> `NotSolved msid) (P.solve t) in

    let m = Core.Data.({
      plugin  = P.id ;
      data    = P.to_json t ;
      iid     = P.iid t ;
      uid     = P.uid t ;
      solved  ;
      wid     = mwid ;
      time    ; 
      clicked = None ;
      sent    = None ; 
      opened  = None ; 
      blocked = false ;
      accept  = None ;        
      dead    = false ;
      zapped  = None ; 
      item    = P.item t ; 
    }) in

    let! mid = ohm (Core.Tbl.create m) in
    return () 

  let send_many ?time ?mwid ts = 
    let mwid = match mwid with Some mwid -> mwid | None -> IMail.Wave.gen () in
    Run.list_iter (send_one ?time ~mwid) ts

  (* Solving forwards the right arguments *)

  let solve sid = solve (P.id,sid) 

end 
