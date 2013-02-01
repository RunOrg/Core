(* © 2012 RunOrg *)

type 'relation t 

val try_get : 'any MActor.t -> 'a IFeed.id -> 'a t option O.run
val get_for_owner : 'any MActor.t -> 'a IFeedOwner.id  -> [`Unknown] t O.run

val bot_get : [`Bot] IFeed.id -> [`Bot] t option O.run

val try_by_owner : 'a IFeedOwner.id -> (#O.ctx,IFeed.t option) Ohm.Run.t 

module Get : sig

  val id    : 'any t -> 'any IFeed.id

  val notified    : [`Bot] t -> MAccess.t list O.run
  val read_access : [`Bot] t -> MAccess.t list O.run

  val owner : 'any t -> IFeedOwner.t
  val instance : 'any t -> IInstance.t

end

module Can : sig
  val admin : 'any t -> [`Admin] t option O.run
  val write : 'any t -> [`Write] t option O.run
  val read  : 'any t -> [`Read] t option O.run
end
  
