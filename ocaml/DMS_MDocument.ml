(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type 'relation t = 'relation DMS_MDocument_can.t
type version     = DMS_MDocument_get.version 

module Can       = DMS_MDocument_can 
module Get       = DMS_MDocument_get
module Set       = DMS_MDocument_set
module All       = DMS_MDocument_all
module Upload    = DMS_MDocument_upload
module E         = DMS_MDocument_core

include HEntity.Get(Can)(E)

let instance did = 
  let! doc = ohm_req_or (return None) (get did) in
  return $ Some (Get.iid doc)

let create ~self ~iid rid =
  Upload.create ~self ~iid rid 
  
let ready fid = 
  Upload.ready fid 

let add_version ~self ~iid t = 
  Upload.add_version ~self ~iid t
