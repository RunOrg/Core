(* © 2013 RunOrg *)

type status =
  [ `Pending
  | `Invited
  | `Member 
  | `Declined ] 

module Signals : sig
  val is_in_group : 
    (IAvatar.t * status * IAvatarSet.t, bool O.run) Ohm.Sig.channel
  val all_in_group : 
    ([`Bot] IInstance.id * status * [`List] IAvatarSet.id * IAvatar.t option * int, 
     IAvatar.t list O.run) Ohm.Sig.channel
end

type t 

val admins : t
val everyone : t
val nobody : t
val avatars : IAvatar.t list -> t
val group : status -> IAvatarSet.t -> t
val group2 : status list -> IAvatarSet.t -> t
val groups : status -> IAvatarSet.t list -> t

val is_in : 'any MActor.t -> t -> (#O.ctx, bool) Ohm.Run.t

val (+) : t -> t -> t 
val union : t list -> t 

val iter : 
  (* Call at initialization time *)
     string
  -> 'persist Ohm.Fmt.fmt
  -> ('persist -> IAvatar.t -> unit O.run) 
  -> ('persist -> unit O.run) 
  (* Call to start processing *)
  -> ([`Bot] IInstance.id -> t -> 'persist -> unit O.run) 
