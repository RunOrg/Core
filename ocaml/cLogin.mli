(* © 2012 RunOrg *)

module Lost : sig
  val send_reset_mail : 'a IUser.id -> unit O.run
end

module Facebook : sig
  val confirm : 
    ([`CanLogin] IUser.id -> O.Action.response O.run) ->
    Ohm.I18n.t ->
    < cookie : string -> string option ; .. > ->
    O.Action.response ->
    O.Action.response O.run
end
