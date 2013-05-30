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

(* React to group updates to create atoms. *)

let () = 
  let! gid = Sig.listen Signals.on_update in 

  (* TODO : react when group is deleted *)  
  let! group = ohm_req_or (return ()) (E.Tbl.get (IGroup.decay gid)) in

  let  limited = match group.E.vision with 
    | `Public
    | `Normal -> false
    | `Private -> true in

  let! name = ohm (match group.E.name with 
    | Some n -> TextOrAdlib.to_string n
    | None   -> AdLib.get `Group_Unnamed) in

  let iid = group.E.iid in

  MAtom.reflect iid `Group (IGroup.to_id gid) ~lim:limited name 
