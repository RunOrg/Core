(* © 2013 RunOrg *)

module Plugin : Ohm.Id.PHANTOM
module Solve  : Ohm.Id.PHANTOM
module Action : Ohm.Id.PHANTOM

include Ohm.Id.PHANTOM
  
module Assert : sig
  val bot      : 'any id -> [`Bot] id
  val can_read : 'any id -> [`Read] id
  val can_send : 'any id -> [`Send] id
end


