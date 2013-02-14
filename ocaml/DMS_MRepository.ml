(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type 'relation t = 'relation DMS_MRepository_can.t

module Remove    = DMS_MRepository_remove
module Detail    = DMS_MRepository_detail
module Upload    = DMS_MRepository_upload
module Vision    = DMS_MRepository_vision 
module Can       = DMS_MRepository_can 
module Get       = DMS_MRepository_get
module Set       = DMS_MRepository_set
module All       = DMS_MRepository_all
module E         = DMS_MRepository_core

include HEntity.Get(Can)(E)

let delete t self = 
  Set.update [`Delete (IAvatar.decay (MActor.avatar self))] t self 

let instance eid = 
  let! repository = ohm_req_or (return None) (get eid) in
  return $ Some (Get.iid repository)

let create ~self ~name ~vision ~upload ~iid = 

  O.decay begin 

    let iid = IInstance.decay iid in 
    let rid = DMS_IRepository.gen () in
    
    let admins = 
      if None = MActor.admin self then `List [IAvatar.decay (MActor.avatar self)] 
      else `Nobody
    in

    let upload = match upload with 
      | `List -> `List []
      | `Viewers -> `Viewers
    in

    let init = E.({
      iid    ;
      name   ;
      vision ;
      upload ; 
      detail = `Public ;
      remove = `Free ; 
      admins ;
      del    = None ;
    }) in
    
    let! _ = ohm $ E.create rid self init [] in
    
    return rid

  end
