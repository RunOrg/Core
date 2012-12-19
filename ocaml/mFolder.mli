(* © 2012 RunOrg *)

type 'relation t

val try_get        : 'any # MAccess.context -> 'a IFolder.id  -> 'a t option O.run
val get_for_event  : 'any # MAccess.context -> 'a IEvent.id   -> [`Unknown] t O.run
val get_for_entity : 'any # MAccess.context -> 'a IEntity.id  -> [`Unknown] t O.run

module Get : sig
  val id     : 'any t -> 'any IFolder.id
  val owner : 'any t -> [ `Entity of IEntity.t | `Event of IEvent.t ]
  val instance : 'any t -> IInstance.t
  val write_instance : [`Write] t -> [`Upload] IInstance.id
end

module Can : sig
  val admin : 'any t -> [`Admin] t option O.run
  val write : 'any t -> [`Write] t option O.run
  val read  : 'any t -> [`Read] t option O.run
end
