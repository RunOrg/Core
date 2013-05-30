(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common

let search actor key atid = 
  let  default = Action.url Url.home key [] in 
  let  did = IDocument.of_id (IAtom.to_id atid) in
  let! doc = ohm_req_or (return default) (MDocument.view ~actor did) in
  let  rids = MDocument.Get.repositories doc in 
  let! repo = ohm_req_or (return default) (Run.list_find (MRepository.view ~actor) rids) in
  let  rid  = MRepository.Get.id repo in
  return (Action.url Url.file key [ IRepository.to_string rid ; IDocument.to_string did ])
    
let () = CAtom.register ~search `DMS_Document
