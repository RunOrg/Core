(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Core = MNotif_core

module type PLUGIN = sig
  include Ohm.Fmt.FMT
  val id : IMail.Plugin.t
  val iid : t -> IInstance.t option 
  val uid : t -> IUser.t 
  val from : t -> IAvatar.t option     
  val solve : t -> IMail.Solve.t option 
end

(* Marking solvable items as solved *) 

module SolveArgs = Fmt.Make(struct type json t = (IMail.Plugin.t * IMail.Solve.t) end)

module SolvableView = CouchDB.DocView(struct
  module Key = SolveArgs
  module Value = Fmt.Unit
  module Doc = Core.Data
  module Design = Core.Design
  let name = "solvable"
  let map = "if (!doc.dead && doc.solve !== null && doc.solved === null) emit([doc.plugin,doc.solve]);"
end)

let task_solve, def_solve = O.async # declare "notif-solve" SolveArgs.fmt
let solve key =
  let! now  = ohmctx (#time) in
  let! mids = ohm (SolvableView.doc_query ~startkey:key ~endkey:key ~endinclusive:true ~limit:5 ()) in
  if mids = [] then return () else
    let! () = ohm (Run.list_iter begin fun x ->
      let mid = IMail.of_id (x # id) in
      Core.Tbl.update mid (fun n -> Core.Data.({ n with solved = Some now })) 
    end mids) in
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
  match get_parser t.Core.Data.plugin with 
    | None -> return None
    | Some parse -> parse mid t

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
    let  stub = Core.Data.(object
      method plugin = P.id
      method id     = mid
      method mid    = m.mid
      method iid    = m.iid
      method uid    = m.uid
      method from   = P.from t 
      method time   = m.time
      method read   = m.read
      method sent   = m.sent
      method solved = if m.solve <> None then m.solved else m.read
      method nmc    = m.nmc
      method nsc    = m.nsc
      method nzc    = m.nzc
      method inner  = t
    end) in 
    let! r = ohm_req_or (return None) (render stub) in
    return (Some Core.Data.(object 
      method plugin = P.id
      method id     = mid
      method mid    = m.mid
      method iid    = m.iid
      method uid    = m.uid
      method from   = P.from t 
      method time   = m.time
      method read   = m.read
      method sent   = m.sent
      method solved = if m.solve <> None then m.solved else m.read
      method nmc    = m.nmc
      method nsc    = m.nsc
      method nzc    = m.nzc
      method mail u = r # mail u 
      method list   = r # list
      method act a  = r # act a 
    end))

  let () = add_parser P.id parse

  (* Sending one notification serves as base for sending many. *)

  let send_one ?time ?mid t =

    let! time' = ohmctx (#time) in
    let  time  = BatOption.default time' time in 

    let mid = match mid with Some mid -> mid | None -> IMailing.gen () in
    
    let m = Core.Data.({
      plugin = P.id ;
      data   = P.to_json t ;
      iid    = P.iid t ;
      uid    = P.uid t ;
      solve  = P.solve t ;
      mid    ;
      time   ; 
      nmc    = 0 ;
      nsc    = 0 ;
      nzc    = 0 ; 
      solved = None ;
      sent   = None ;
      read   = None ; 
      dead   = false ;       
    }) in

    let! mid = ohm (Core.Tbl.create m) in
    return () 

  let send_many ?time ?mid ts = 
    let mid = match mid with Some mid -> mid | None -> IMailing.gen () in
    Run.list_iter (send_one ?time ~mid) ts

  (* Solving forwards the right arguments *)

  let solve sid = solve (P.id,sid) 

end 
