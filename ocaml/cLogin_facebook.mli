(* © 2012 RunOrg *)

val confirm : 
  ([`CanLogin] IUser.id -> O.Action.response O.run) ->
  Ohm.I18n.t ->
  < cookie : string -> string option ; .. > ->
  O.Action.response ->
  O.Action.response O.run

