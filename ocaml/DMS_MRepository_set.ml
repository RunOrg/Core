(* © 2013 RunOrg *)
  
open Ohm
open Ohm.Universal
open BatPervasives
  
module E    = DMS_MRepository_core
module Can  = DMS_MRepository_can

include HEntity.Set(Can)(E)

let admins aids t self = 
  let aids = BatList.sort_unique compare aids in
  if aids <> List.sort compare (MAccess.delegates (Can.data t).E.admins) then
    let admins = MAccess.set_delegates aids (Can.data t).E.admins in 
    update [`SetAdmins admins] t self
  else
    return ()
    
let info ~name ~vision t self = 
  let e = Can.data t in 
  let diffs = BatList.filter_map identity [
    (if name   = e.E.name   then None else Some (`SetName name)) ;
    (if vision = e.E.vision then None else Some (`SetVision vision)) ;
  ] in
  let! () = ohm (if diffs = [] then return () else update diffs t self) in
  return ()
