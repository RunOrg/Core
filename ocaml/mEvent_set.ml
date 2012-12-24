(* © 2012 RunOrg *)
  
open Ohm
open Ohm.Universal
open BatPervasives
  
module E    = MEvent_core
module Can  = MEvent_can
module Data = MEvent_data

let update t self diffs = 
  O.decay begin 
    let info = MUpdateInfo.self (MActor.avatar self) in 
    let! _ = ohm $ E.Store.update ~id:(IEvent.decay (Can.id t)) ~diffs ~info () in
    return () 
  end

let picture t self fid = 
  let fid = BatOption.map IFile.decay fid in 
  if fid = (Can.data t).E.pic then return () else 
    update t self [`SetPicture fid]
    
let admins t self aids = 
  if List.sort compare aids <> List.sort compare (MAccess.delegates (Can.data t).E.admins) then
    let admins = MAccess.set_delegates aids (Can.data t).E.admins in 
    update t self [`SetAdmins admins]
  else
    return ()
    
let info t self ~draft ~name ~page ~date ~address ~vision = 
  let e = Can.data t in 
  let diffs = BatList.filter_map identity [
    (if draft = e.E.draft then None else Some (`SetDraft draft)) ;
    (if name = e.E.name then None else Some (`SetName name)) ;
    (if date = e.E.date then None else Some (`SetDate date)) ;
    (if vision = e.E.vision then None else Some (`SetVision vision)) ;
  ] in
  let! () = ohm (if diffs = [] then return () else update t self diffs) in
  let! () = ohm $ Data.update (Can.id t) self ~page ~address in 
  return ()
