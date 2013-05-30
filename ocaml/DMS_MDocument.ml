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
module Atom      = DMS_MDocument_atom

include HEntity.Get(Can)(E)

module Search = struct
  let by_atom ~actor ?start ~count atom = 
    let! list, next = ohm (DMS_MDocMeta.Search.by_atom ?start ~count atom) in
    let! list = ohm $ Run.list_filter (view ~actor) list in 
    return (list, next) 
end

let instance did = 
  let! doc = ohm_req_or (return None) (get did) in
  return $ Some (Get.iid doc)

let create ~self ~iid rid =
  Upload.create ~self ~iid rid 
  
let ready fid = 
  Upload.ready fid 

let add_version ~self ~iid t = 
  Upload.add_version ~self ~iid t

module Backdoor = struct
  let refresh_atoms cuid = 
    Atom.refresh_atoms cuid 
end
