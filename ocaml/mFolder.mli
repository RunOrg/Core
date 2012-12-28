(* © 2012 RunOrg *)

type 'relation t

val try_get        : 'any MActor.t -> 'a IFolder.id  -> 'a t option O.run
val get_for_owner  : 'any MActor.t -> 'a IFolderOwner.id -> [`Unknown] t O.run

val bot_get : [`Bot] IFolder.id -> (#O.ctx,[`Bot] t option) Ohm.Run.t

val by_owner : 'a IInstance.id -> 'b IFolderOwner.id -> IFolder.t O.run

val try_by_owner : 'a IFolderOwner.id -> (#O.ctx,IFolder.t option) Ohm.Run.t 

module Get : sig
  val id     : 'any t -> 'any IFolder.id
  val owner  : 'any t -> IFolderOwner.t
  val instance : 'any t -> IInstance.t
  val write_instance : [`Write] t -> [`Upload] IInstance.id
end

module Can : sig
  val admin : 'any t -> [`Admin] t option O.run
  val write : 'any t -> [`Write] t option O.run
  val read  : 'any t -> [`Read] t option O.run
end
