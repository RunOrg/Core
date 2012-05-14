(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val is_admin  : 'any id -> [`Admin]  id
  val is_safe   : 'any id -> [`Safe]   id
  val is_unsafe : 'any id -> [`Unsafe] id
end
  
module Deduce : sig
  val is_safe   : [`Admin] id -> [`Safe] id
  val is_unsafe : [<`Admin|`Safe] id -> [`Unsafe] id
end

val prove : string -> 'any id -> string list -> string
val is_proof : string -> string -> 'any id -> string list -> bool
