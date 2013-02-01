(* © 2013 RunOrg *)

type 'relation t

val try_get        : 'any MActor.t -> 'a IAlbum.id  -> 'a t option O.run
val get_for_owner  : 'any MActor.t -> 'a IAlbumOwner.id  -> [`Unknown] t O.run 

val bot_get : [`Bot] IAlbum.id -> (#O.ctx,[`Bot] t option) Ohm.Run.t

val by_owner : 'a IInstance.id -> 'b IAlbumOwner.id -> IAlbum.t O.run

val try_by_owner : 'a IAlbumOwner.id -> (#O.ctx,IAlbum.t option) Ohm.Run.t 

module Get : sig
  val id       : 'any t -> 'any IAlbum.id
  val owner    : 'any t -> IAlbumOwner.t
  val instance : 'any t -> IInstance.t
  val write_instance : [`Write] t -> [`Upload] IInstance.id
end

module Can : sig
  val admin : 'any t -> [`Admin] t option O.run
  val write : 'any t -> [`Write] t option O.run
  val read  : 'any t -> [`Read] t option O.run
end
