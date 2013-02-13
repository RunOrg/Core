(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM

module Assert : sig
  val admin  : 'any id -> [`Admin] id
  val view   : 'any id -> [`View]  id 
  val upload : 'any id -> [`Upload] id 
end
