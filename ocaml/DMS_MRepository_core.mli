(* © 2013 RunOrg *)

type data_t = {
  iid    : IInstance.t ;
  name   : string ;
  vision : DMS_MRepository_vision.t ;
  upload : DMS_MRepository_upload.t ; 
  admins : MAccess.t ;
  del    : IAvatar.t option ;
}

type diff_t = 
  [ `SetName    of string
  | `SetVision  of DMS_MRepository_vision.t
  | `SetUpload  of DMS_MRepository_upload.t 
  | `SetAdmins  of MAccess.t	  
  | `Delete     of IAvatar.t
  ]

include HEntity.CORE
 with type t    = data_t
 and  type diff = diff_t
 and  type Id.t = DMS_IRepository.t
