(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val view : 'any id -> [`View] id
end
  
module Deduce : sig
  val make_view_token : [`Unsafe] ICurrentUser.id -> [`View] id -> string
  val from_view_token : [`Unsafe] ICurrentUser.id -> 'any id -> string -> [`View] id option
end
