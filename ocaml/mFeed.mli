(* © 2012 RunOrg *)

type 'relation t 

val try_get : 'any # MAccess.context -> 'a IFeed.id -> 'a t option O.run
val get_for_entity   : 'any # MAccess.context -> 'a IEntity.id  -> [`Unknown] t O.run
val get_for_instance : 'any # MAccess.context                   -> [`Unknown] t O.run
val get_for_message  : 'any # MAccess.context -> 'a IMessage.id -> [`Unknown] t O.run

val bot_get : [`Bot] IFeed.id -> [`Bot] t option O.run

val bot_find : 
     IInstance.t
  -> [`of_entity of IEntity.t|`of_message of IMessage.t] option
  -> [`Bot] IFeed.id O.run

module Get : sig
  val notified : [`Bot] t -> MAccess.t list O.run
  val read_access : [`Bot] t -> MAccess.t list O.run
  val id     : 'any t -> 'any IFeed.id
  val owner :
       'any t
    -> [ `of_instance of IInstance.t
       | `of_entity of IEntity.t
       | `of_message of IMessage.t] 
  val instance : 'any t -> IInstance.t
end

module Can : sig
  val admin : 'any t -> [`Admin] t option O.run
  val write : 'any t -> [`Write] t option O.run
  val read  : 'any t -> [`Read] t option O.run
end
  
