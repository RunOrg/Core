(* © 2013 RunOrg *) 

include Ohm.Id.PHANTOM

module Assert : sig
  val read : 'any id -> [`Read] id
end

module Deduce : sig
  val make_read_token  : 'u ICurrentUser.id -> [`Read] id  -> string
  val from_read_token  : 'u ICurrentUser.id -> 'any id     -> string -> [`Read] id option
end
