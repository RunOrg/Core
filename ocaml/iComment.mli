(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val created : 'any id -> [`Created] id
  val read    : 'any id -> [`Read] id
end
  
module Deduce : sig
end


