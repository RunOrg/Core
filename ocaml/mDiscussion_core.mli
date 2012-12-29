(* © 2012 RunOrg *)

type data_t = {
  iid   : IInstance.t ;
  gids  : IGroup.t list ; 
  title : string ; 
  body  : MRich.OrText.t ;
  time  : float ;
  crea  : IAvatar.t ;
  del   : IAvatar.t option ;
}

type diff_t = 
  [ `SetTitle  of string
  | `SetBody   of MRich.OrText.t
  | `AddGroups of IGroup.t list 
  | `Delete    of IAvatar.t
  ]

include HEntity.CORE
 with type t    = data_t
 and  type diff = diff_t
 and  type Id.t = IDiscussion.t
