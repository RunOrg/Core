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
module E         = DMS_MDocument_core

include HEntity.Get(Can)(E)

let instance did = 
  let! doc = ohm_req_or (return None) (get did) in
  return $ Some (Get.iid doc)

let create ~self ~name ~iid rid =
  
  O.decay begin
    
    let iid = IInstance.decay iid in
    let rid = DMS_IRepository.decay rid in 
    let did = DMS_IDocument.gen () in
    let aid = IAvatar.decay (MActor.avatar self) in 

    let! now = ohmctx (#time) in
    
    let init = E.({ 
      iid     ;
      name    ;
      repos   = [ rid ];
      version = None ;
      creator = aid ;
      last    = (now, aid) ;
    }) in

    let! _ = ohm $ E.create did self init [] in

    return did

  end
