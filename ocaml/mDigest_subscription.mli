(* © 2012 RunOrg *)

module Signals : sig
  val on_follow : (IDigest.t * IInstance.t, unit O.run) Ohm.Sig.channel
  val on_unfollow : (IDigest.t * IInstance.t, unit O.run) Ohm.Sig.channel
end

val subscribe : 'a IDigest.id -> 'b IInstance.id -> unit O.run
val unsubscribe : 'a IDigest.id -> 'b IInstance.id -> unit O.run
val add_through : 'a IDigest.id -> 'b IInstance.id -> through:'c IInstance.id -> unit O.run
val remove_through : 'a IDigest.id -> 'b IInstance.id -> through:'c IInstance.id -> unit O.run
val remove_all_through : 'a IDigest.id -> 'b IInstance.id -> unit O.run

val follows : 'a IDigest.id -> 'b IInstance.id -> bool O.run

val count_followers : 'a IInstance.id -> int O.run

val followers : 
     ?start:IDigest.t
  ->  count:int
  ->  IInstance.t
  ->  (IDigest.t list * IDigest.t option) O.run


module Backdoor : sig

  val count : < direct : int ; member : int ; through : int ; blocked : int > O.run

end
