(* © 2013 RunOrg *)

module Signals : sig
  val on_appear : (IChat.Room.t, unit O.run) Ohm.Sig.channel
  val on_create : ([`Created] IChat.Room.id * [`Write] MFeed.t, unit O.run) Ohm.Sig.channel
end

val recent : 
     [`Write] MFeed.t
  -> ([`Post] IChat.Room.id * [`View] IChat.Room.id option) O.run

val close  : 'any IChat.Room.id -> unit O.run
val url    : 'any IChat.Room.id -> [`IsSelf] IAvatar.id -> string option O.run
val send   : 'any IChat.Room.id -> MChat_line.t -> unit O.run
val active : 'any IChat.Room.id -> [`Post] IChat.Room.id option O.run
val ensure : 'any IChat.Room.id -> unit O.run

val readable : 'any IChat.Room.id -> [`Read] IFeed.id -> [`View] IChat.Room.id option O.run

val all_active : 'any IInstance.id -> IFeed.t list O.run
