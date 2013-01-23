(* © 2012 RunOrg *)

type t 

val group : string -> t -> IAvatarSet.t O.run
val entity : string -> t -> IEntity.t O.run

val set_admin : t -> IEntity.t -> IAvatarSet.t -> unit O.run

val load : 'any IInstance.id -> t
