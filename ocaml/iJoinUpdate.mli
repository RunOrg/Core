(* © 2012 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val cancel : 'any id -> [`Cancel] id
end

module Deduce : sig
end    
