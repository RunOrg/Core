(* © 2013 RunOrg *)

val send : (IUser.t, unit O.run) Ohm.Sig.channel

module Backdoor : sig

  val migrate_confirmed : unit -> unit O.run 

end
