(* © 2013 RunOrg *)

module Signals : sig
  val is_in_group : 
    (IAvatar.t * IAvatarSet.t, bool O.run) Ohm.Sig.channel
end

val in_group : IAvatar.t -> IAvatarSet.t -> (#O.ctx,bool) Ohm.Run.t

val test : 'any MActor.t -> IDelegation.t -> (#O.ctx,bool) Ohm.Run.t

val (+) : IDelegation.t -> IDelegation.t -> IDelegation.t

val stream : IDelegation.t -> MAvatarStream.t
