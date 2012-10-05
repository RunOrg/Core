(* © 2012 RunOrg *)

val core : string -> IWhite.t option Ohm.Action.server
val secure : string -> IWhite.t option Ohm.Action.server
val client : string -> (string * IWhite.t option) Ohm.Action.server
