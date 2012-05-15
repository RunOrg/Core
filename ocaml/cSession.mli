(* © 2012 RunOrg *)

val start : [`CanLogin] IUser.id -> Ohm.Action.response -> Ohm.Action.response
val check : ('a,'b) Ohm.Action.request -> ICurrentUser.t option
val close : Ohm.Action.response -> Ohm.Action.response
