(* © 2012 RunOrg *)

type 'relation what = [ `item    of 'relation IItem.id ]

module Signals : sig      
  val on_like   : (IAvatar.t * [`Liked] what, unit O.run) Ohm.Sig.channel
  val on_unlike : (IAvatar.t * [`Liked] what, unit O.run) Ohm.Sig.channel
end
  
val likes  : [`IsSelf] IAvatar.id ->    'any what -> bool O.run
val like   : [`IsSelf] IAvatar.id -> [`Like] what -> unit O.run
val unlike : [`IsSelf] IAvatar.id ->    'any what -> unit O.run

val count : 'any what -> int O.run

val interested : [`Bot] IItem.id -> IAvatar.t list O.run
  
module Backdoor : sig
  val count : unit -> int O.run
end
