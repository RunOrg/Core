(* © 2012 RunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val exec : 'any id -> [`Exec] id
end

module Deduce : sig

  val make_exec_token  : [`Unsafe] ICurrentUser.id -> [`Exec] id  -> string
  val from_exec_token  : [`Unsafe] ICurrentUser.id -> 'any id     -> string -> [`Exec] id option

end
