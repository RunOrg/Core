(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val read : 'any id -> [`Read] id
  val bot  : 'any id -> [`Bot] id
end
  
module Deduce : sig
end
