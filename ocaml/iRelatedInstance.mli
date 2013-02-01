(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val view  : 'any id -> [`View]  id
  val admin : 'any id -> [`Admin] id
  val own   : 'any id -> [`Own]   id
end
  
module Deduce : sig
end
