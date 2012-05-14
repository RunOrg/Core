(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val cancel : 'any id -> [`Cancel] id
end

module Deduce : sig
end    
