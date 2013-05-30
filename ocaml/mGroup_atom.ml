(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module E         = MGroup_core
module Signals   = MGroup_signals
module Can       = MGroup_can 

(* Register group visibility test *) 

let () = 
  MAtom.access_register `Group begin fun actor id -> 
    let  gid = IGroup.of_id id in 
    let! group = ohm_req_or (return false) (E.Tbl.get (IGroup.decay gid)) in
    let! can = req_or (return false) (Can.make gid ~actor group) in
    let! view = ohm_req_or (return false) (Can.view can) in
    return true
  end

(* Create an atom from a group id *)

let reflect gid = 

  let! group = ohm_req_or (return ()) (E.Tbl.get (IGroup.decay gid)) in

  let  limited = match group.E.vision with 
    | `Public
    | `Normal -> false
    | `Private -> true in

  (* React when group is deleted *)
  let limited = limited || group.E.del <> None in 
  let hide = group.E.del <> None in 

  let! name = ohm (match group.E.name with 
    | Some n -> TextOrAdlib.to_string n
    | None   -> AdLib.get `Group_Unnamed) in

  let iid = group.E.iid in

  MAtom.reflect iid `Group (IGroup.to_id gid) ~lim:limited ~hide name 


(* React to group updates to create atoms. *)

let () = 
  Sig.listen Signals.on_update reflect 

(* API-controlled refresh of all groups *)

let refresh_group_atoms = Async.Convenience.foreach O.async "refresh-group-atoms"
  IGroup.fmt (E.Tbl.all_ids ~count:10) 
  (fun gid -> 
    let () = Util.log "Reflect group %s" (IGroup.to_string gid) in 
    reflect gid)
  
let refresh_group_atoms cuid = 
  O.decay (refresh_group_atoms ())
