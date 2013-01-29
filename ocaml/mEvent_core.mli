(* © 2012 RunOrg *)

type data_t = {
  iid    : IInstance.t ;
  tid    : ITemplate.Event.t ;
  gid    : IAvatarSet.t ;
  name   : string option ;
  date   : Date.t option ;
  pic    : IFile.t option ;
  vision : MEvent_vision.t ;
  admins : MAccess.t ;
  draft  : bool ;
  config : MEvent_config.t ;
  del    : IAvatar.t option ;
}

type diff_t = 
  [ `SetDraft   of bool 
  | `SetName    of string option
  | `SetVision  of MEvent_vision.t
  | `SetPicture of IFile.t option
  | `SetDate    of Date.t option 
  | `SetAdmins  of MAccess.t	  
  | `EditConfig of MEvent_config.Diff.t list
  | `Delete     of IAvatar.t
  ]

include HEntity.CORE
 with type t    = data_t
 and  type diff = diff_t
 and  type Id.t = IEvent.t
