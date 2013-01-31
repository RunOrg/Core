(* © 2013 RunOrg *)

type t 

val avatarSet : string -> t -> (#O.ctx, IAvatarSet.t) Ohm.Run.t
val group : string -> t -> (#O.ctx,IGroup.t) Ohm.Run.t

val set_admin : t -> IGroup.t -> IAvatarSet.t -> (#O.ctx,unit) Ohm.Run.t

val load : 'any IInstance.id -> t
