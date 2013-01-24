(* © 2012 RunOrg *)

type data_t = {
  iid    : IInstance.t ;
  tid    : ITemplate.Group.t ;
  gid    : IAvatarSet.t ;
  name   : TextOrAdlib.t option ;
  vision : MGroup_vision.t ;
  admins : MAccess.t ;
  config : MGroup_config.t ;
  del    : IAvatar.t option ;
}

type diff_t = 
  [ `SetName    of TextOrAdlib.t option
  | `SetVision  of MGroup_vision.t
  | `SetAdmins  of MAccess.t	  
  | `EditConfig of MGroup_config.Diff.t list
  | `Delete     of IAvatar.t
  ]

include HEntity.CORE
 with type t    = data_t
 and  type diff = diff_t
 and  type Id.t = IGroup.t
