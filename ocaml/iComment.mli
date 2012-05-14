(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val created : 'any id -> [`Created] id
  val read    : 'any id -> [`Read] id
  val liked   : 'any id -> [`Liked] id
end
  
module Deduce : sig
  val read_can_like  : [`Read] id -> [`Like] id
    
  val make_like_token : [`Unsafe] ICurrentUser.id -> [`Like] id -> string
  val from_like_token : [`Unsafe] ICurrentUser.id -> 'any id    -> string -> [`Like] id option
end


