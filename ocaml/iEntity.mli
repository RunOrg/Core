(* © 2012 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val created       : 'any id -> [`Created] id
  val admin         : 'any id -> [`Admin] id
  val view          : 'any id -> [`View] id
  val can_invite    : 'any id -> [`Invite] id
  val bot           : 'any id -> [`Bot] id
end

module Deduce : sig
end
