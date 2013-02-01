(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val is_self : 'any id -> [`IsSelf] id
  val bot     : 'any id -> [`Bot]    id
end
  
module Deduce : sig
  val make_token : [`Unsafe] ICurrentUser.id -> [`IsSelf] id -> string
  val from_token : [`Unsafe] ICurrentUser.id -> 'any id      -> string -> [`IsSelf] id option
end

