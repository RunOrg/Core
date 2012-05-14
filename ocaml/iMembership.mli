(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val write : 'any id -> [`Write] id
  val read  : 'any id -> [`Read] id
  val bot   : 'any id -> [`Bot] id
  val self  : 'any id -> [`IsSelf] id
  val admin : 'any id -> [`IsAdmin] id
end

module Deduce : sig
end
