(* © 2013 RunOrg *)

type data_t = {
  iid    : IInstance.t ;
  name   : string ;
  vision : DMS_MRepository_vision.t ;
  upload : DMS_MRepository_upload.t ; 
  remove : DMS_MRepository_remove.t ;
  detail : DMS_MRepository_detail.t ; 
  admins : IDelegation.t ;
  del    : IAvatar.t option ;
}

type diff_t = 
  [ `SetName    of string
  | `SetVision  of DMS_MRepository_vision.t
  | `SetUpload  of DMS_MRepository_upload.t 
  | `SetRemove  of DMS_MRepository_remove.t
  | `SetDetail  of DMS_MRepository_detail.t
  | `SetAdmins  of IDelegation.t	  
  | `Delete     of IAvatar.t
  ]

include HEntity.CORE
 with type t    = data_t
 and  type diff = diff_t
 and  type Id.t = DMS_IRepository.t
