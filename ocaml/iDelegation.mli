(* © 2013 RunOrg *)

type specific = private { 
  avatars : IAvatar.t list ;
  groups  : IAvatarSet.t list 
}
  
include Ohm.Fmt.FMT with type t = 
  [ `Admin 
  | `Everyone
  | `Specific of specific ]

val union : t -> t -> t 

val make : avatars:IAvatar.t list -> groups:IAvatarSet.t list -> t

val set_avatars : IAvatar.t list -> t -> t 

val avatars : t -> IAvatar.t list 
