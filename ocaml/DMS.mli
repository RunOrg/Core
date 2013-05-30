(* © 2013 RunOrg *)

module MDocument : sig
  module Backdoor : sig
    val refresh_atoms : [`Admin] ICurrentUser.id -> (#O.ctx,unit) Ohm.Run.t
  end
end
