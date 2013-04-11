(* © 2013 RunOrg *)

module Email : sig

  type t = <
    itid : IItem.t ;
    aid  : IAvatar.t ;
    iid  : IInstance.t ; 
    uid  : IUser.t ;
    kind : [ `Mail ] ;
  >

  val define : 
    ([`IsSelf] IUser.id -> MUser.t -> t -> MMail.Types.info -> MMail.Types.render option O.run) -> unit

end

module Comment : sig

  type t = <
    uid : IUser.t ;
    iid : IInstance.t ;
    aid : IAvatar.t ;
    cid : IComment.t ;	
  > 

  val define : 
    ([`IsSelf] IUser.id -> MUser.t -> t -> MMail.Types.info -> MMail.Types.render option O.run) -> unit

end
