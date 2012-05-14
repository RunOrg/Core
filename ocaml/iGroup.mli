(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
type membership = t -> [`In] id option
    
module Assert : sig
  val is_in : 'any id -> [`In]    id
  val write : 'any id -> [`Write] id
  val admin : 'any id -> [`Admin] id
  val list  : 'any id -> [`List]  id 
  val bot   : 'any id -> [`Bot]   id
end
    
