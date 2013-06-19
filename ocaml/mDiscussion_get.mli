(* © 2013 RunOrg *)

type 'a t = 'a MDiscussion_can.t 

val id       : 'any t ->'any IDiscussion.id
val title    : 'any t -> string
val update   : 'any t -> float
val creator  : 'any t -> IAvatar.t
val iid      : 'any t -> IInstance.t 
val groups   : 'any t -> IAvatarSet.t list
val body     : 'any t -> MRich.OrText.t
val avatars  : 'any t -> IAvatar.t list 
