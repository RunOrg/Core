(* © 2012 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val read  : 'any id -> [`Read]  id
  val vote  : 'any id -> [`Vote]  id
  val admin : 'any id -> [`Admin] id
end
  
module Deduce : sig
end
