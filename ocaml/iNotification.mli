(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val bot      : 'any id -> [`Bot] id
  val can_read : 'any id -> [`Read] id
  val can_send : 'any id -> [`Send] id
end

module Deduce : sig
end

