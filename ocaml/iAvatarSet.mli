(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM
    
module Assert : sig
  val write : 'any id -> [`Write] id
  val admin : 'any id -> [`Admin] id
  val list  : 'any id -> [`List]  id 
  val bot   : 'any id -> [`Bot]   id
end
    
