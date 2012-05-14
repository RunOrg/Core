(* © 2012 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val list : 'any id -> [`List] id
  val edit : 'any id -> [`Edit] id
end
  
module Deduce : sig
  val make_list_token : [`Unsafe] ICurrentUser.id -> [`List] id -> string
  val from_list_token : [`Unsafe] ICurrentUser.id -> 'any id    -> string -> [`List] id option
end
