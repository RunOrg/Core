(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val is_admin  : 'any id -> [`Admin]  id
end
  
module Deduce : sig
end

val prove    : string -> 'any id -> string list -> string
val is_proof : string -> string -> 'any id -> string list -> bool
