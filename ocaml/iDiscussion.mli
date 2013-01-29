(* © 2012 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val admin         : 'any id -> [`Admin] id
  val view          : 'any id -> [`View] id
end

module Deduce : sig
end
