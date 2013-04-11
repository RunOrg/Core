(* © 2013 RunOrg *)

module Invited : sig

  type t = <
    uid  : IUser.t ;
    from : IAvatar.t ; 
    iid  : IInstance.t ;
    eid  : IEvent.t ; 
    mid  : IMembership.t ;
  > ;;

  val define : 
    ([`IsSelf] IUser.id -> MUser.t -> t -> MMail.Types.info -> MMail.Types.render option O.run) -> unit

end
