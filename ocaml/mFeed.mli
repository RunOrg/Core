(* © 2012 RunOrg *)

type 'relation t 

val try_get : 'any # MAccess.context -> 'a IFeed.id -> 'a t option O.run
val get_for_entity   : 'any # MAccess.context -> 'a IEntity.id  -> [`Unknown] t O.run
val get_for_event    : 'any # MAccess.context -> 'a IEvent.id   -> [`Unknown] t O.run
val get_for_instance : 'any # MAccess.context                   -> [`Unknown] t O.run

val bot_get : [`Bot] IFeed.id -> [`Bot] t option O.run

val bot_find : 
     IInstance.t
  -> [`Entity of IEntity.t|`Event of IEvent.t] option
  -> [`Bot] IFeed.id O.run

module Get : sig

  val id    : 'any t -> 'any IFeed.id

  val notified    : [`Bot] t -> MAccess.t list O.run
  val read_access : [`Bot] t -> MAccess.t list O.run

  val owner : 'any t -> [ `Instance  of IInstance.t
			| `Entity    of IEntity.t
			| `Event     of IEvent.t ] 

  val instance : 'any t -> IInstance.t

end

module Can : sig
  val admin : 'any t -> [`Admin] t option O.run
  val write : 'any t -> [`Write] t option O.run
  val read  : 'any t -> [`Read] t option O.run
end
  
