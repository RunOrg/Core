(* © 2013 RunOrg *)

val send : IUser.t -> (IInstance.t,float) BatPMap.t -> (#O.ctx, (IInstance.t,float) BatPMap.t * int) Ohm.Run.t

type t = <
  uid  : IUser.t ;
  list : (IInstance.t * (IInboxLineOwner.t * float * [`Wall|`Folder|`Album] * int) list) list
>

val define : 
  ([`IsSelf] IUser.id -> MUser.t -> t -> MMail.Types.info -> MMail.Types.render option O.run) -> unit

