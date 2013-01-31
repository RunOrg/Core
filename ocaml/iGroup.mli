(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM

val admin : string
val members : string
  
module Assert : sig
  val admin         : 'any id -> [`Admin] id
  val view          : 'any id -> [`View] id
end

module Deduce : sig
end
