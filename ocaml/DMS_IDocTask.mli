(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM

module Assert : sig
  val view : 'any id -> [`View] id
end
