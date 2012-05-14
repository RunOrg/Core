(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val is_self  : 'any id -> [`IsSelf] id
  val created  : 'any id -> [`Created] id
  val updated  : 'any id -> [`Updated] id
  val view     : 'any id -> [`View] id
end
  
module Deduce : sig
  val self_can_view   : [`IsSelf]  id -> [`View] id
  val create_can_view : [`Created] id -> [`View] id
end  

