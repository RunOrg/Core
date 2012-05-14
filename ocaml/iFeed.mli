(* © 2012 RunOrg *)

include Ohm.Id.PHANTOM

module Assert : sig
  val admin : 'any id -> [`Admin] id
  val write : 'any id -> [`Write] id
  val read  : 'any id -> [`Read]  id
  val bot   : 'any id -> [`Bot]   id
end
  
module Deduce : sig
  val can_read : [<`Admin|`Write|`Read] id -> [`Read] id
  val can_write : [<`Admin|`Write] id -> [`Write] id
    
  val make_write_token : [`Unsafe] ICurrentUser.id -> [`Write] id -> bool -> string
  val from_write_token : [`Unsafe] ICurrentUser.id -> 'any id     -> bool -> string -> [`Write] id option
    
  val make_read_token : [`Unsafe] ICurrentUser.id -> [`Read] id  -> bool -> string
  val from_read_token : [`Unsafe] ICurrentUser.id -> 'any id     -> bool -> string -> [`Read] id option
end


