(* © 2013 RunOrg *)

type t = <
  itid : IItem.t ;
  aid  : IAvatar.t ;
  iid  : IInstance.t ; 
  uid  : IUser.t ;
  kind : [ `Mail ] 
>

val define : 
  ([`IsSelf] IUser.id -> MUser.t -> t -> MMail.Types.info -> MMail.Types.render option O.run) -> unit

