(* © 2013 RunOrg *)
  
open Ohm
open Ohm.Universal
open BatPervasives
  
module E    = MGroup_core
module Can  = MGroup_can

include HEntity.Set(Can)(E)

let admins aids t self = 
  let deleg  = (Can.data t).E.admins in 
  let deleg' = IDelegation.set_avatars aids deleg in 
  if deleg <> deleg' then 
    update [`SetAdmins deleg'] t self
  else
    return ()
    
let info ~name ~vision ~listView t self = 
  let e = Can.data t in 
  let diffs = BatList.filter_map identity [
    (if name = e.E.name then None else Some (`SetName name)) ;
    (if vision = e.E.vision then None else Some (`SetVision vision)) ;
    (if e.E.config # group_read = Some listView then None else Some (`EditConfig [`Group_Read listView])) ;
  ] in
  let! () = ohm (if diffs = [] then return () else update diffs t self) in
  return ()
