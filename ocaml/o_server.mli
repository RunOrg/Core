(* © 2013 RunOrg *)

val server : string -> IWhite.t option -> unit Ohm.Action.server
val core : string -> IWhite.t option Ohm.Action.server
val secure : string -> IWhite.t option Ohm.Action.server
val client : string -> IWhite.key Ohm.Action.server
