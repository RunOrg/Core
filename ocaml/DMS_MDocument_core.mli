(* © 2013 RunOrg *)

type data_t = {
  iid     : IInstance.t ;
  name    : string ; 
  repos   : DMS_IRepository.t list ;
  version : DMS_MDocument_version.t ;
  creator : IAvatar.t ; 
  last    : float * IAvatar.t ;
}

type diff_t = 
  [ `SetName    of string
  | `Share      of DMS_IRepository.t 
  | `Unshare    of DMS_IRepository.t 
  | `AddVersion of DMS_MDocument_version.t 
  ]

include HEntity.CORE
 with type t    = data_t
 and  type diff = diff_t
 and  type Id.t = DMS_IDocument.t
