(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val can_create       : 'any id -> [`Create] id
end
  
module Deduce : sig
  val make_create_token : [`Create] id -> [<`IsContact|`IsMember|`IsAdmin] IIsIn.id -> string
  val from_create_token : 'any id      -> [<`IsContact|`IsMember|`isAdmin] IIsIn.id -> string -> [`Create] id option
end

