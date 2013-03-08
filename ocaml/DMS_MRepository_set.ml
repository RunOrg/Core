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
    
let uploaders aids t self = 
  let e = Can.data t in   
  let aids = BatList.sort_unique compare aids in 
  if e.E.upload = `List aids then return () else
    update [`SetUpload (`List aids)] t self

let info ~name ~vision ~upload t self = 
  let e = Can.data t in 
  let diffs = BatList.filter_map identity [
    (if name   = e.E.name   then None else Some (`SetName name)) ;
    (if vision = e.E.vision then None else Some (`SetVision vision)) ;
    (if upload = `List && e.E.upload = `Viewers then Some (`SetUpload (`List [])) else
	if upload = `Viewers && e.E.upload <> `Viewers then Some (`SetUpload `Viewers) else
	  None) ;
  ] in
  if diffs = [] then return () else update diffs t self 

let advanced ~detail ~remove t self = 
  let e = Can.data t in
  let diffs = BatList.filter_map identity [
    (if detail = e.E.detail then None else Some (`SetDetail detail)) ;
    (if remove = e.E.remove then None else Some (`SetRemove remove)) ;
  ] in
  if diffs = [] then return () else update diffs t self
