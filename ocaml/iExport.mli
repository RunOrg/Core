(* © 2012 RunOrg *) 

include Ohm.Id.PHANTOM

module Assert : sig
  val read : 'any id -> [`Read] id
end
