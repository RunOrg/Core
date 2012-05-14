(* © 2012 RunOrg *)

type t 

val group : string -> t -> IGroup.t O.run
val entity : string -> t -> IEntity.t O.run

val set_admin : t -> IEntity.t -> IGroup.t -> unit O.run

val load : 'any IInstance.id -> t
