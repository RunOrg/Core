(* © 2013 RunOrg *)

module Send : sig

  type t = <
    uid  : IUser.t ;
    list : (IInstance.t * (IInboxLineOwner.t * float * [`Wall|`Folder|`Album] * int) list) list  
  >

  val define : 
    ([`IsSelf] IUser.id -> MUser.t -> t -> MMail.Types.info -> MMail.Types.render option O.run) -> unit

end

module Backdoor : sig

  val migrate_confirmed : unit -> unit O.run 

end
