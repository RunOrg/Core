(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val is_admin  : 'any id -> [`Admin]  id
  val is_new    : 'any id -> [`New] id
  val is_old    : 'any id -> [`Old] id
end
  
module Deduce : sig
end

val prove    : string -> 'any id -> string list -> string
val is_proof : string -> string -> 'any id -> string list -> bool
