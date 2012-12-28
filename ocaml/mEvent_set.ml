(* © 2012 RunOrg *)
  
open Ohm
open Ohm.Universal
open BatPervasives
  
module E    = MEvent_core
module Can  = MEvent_can
module Data = MEvent_data

include HEntity.Set(Can)(E.Store)

let picture fid t self = 
  let fid = BatOption.map IFile.decay fid in 
  if fid = (Can.data t).E.pic then return () else 
    update [`SetPicture fid] t self
    
let admins aids t self = 
  if List.sort compare aids <> List.sort compare (MAccess.delegates (Can.data t).E.admins) then
    let admins = MAccess.set_delegates aids (Can.data t).E.admins in 
    update [`SetAdmins admins] t self
  else
    return ()
    
let info ~draft ~name ~page ~date ~address ~vision t self= 
  let e = Can.data t in 
  let diffs = BatList.filter_map identity [
    (if draft = e.E.draft then None else Some (`SetDraft draft)) ;
    (if name = e.E.name then None else Some (`SetName name)) ;
    (if date = e.E.date then None else Some (`SetDate date)) ;
    (if vision = e.E.vision then None else Some (`SetVision vision)) ;
  ] in
  let! () = ohm (if diffs = [] then return () else update diffs t self) in
  let! () = ohm $ Data.update (Can.id t) self ~page ~address in 
  return ()
