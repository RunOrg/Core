(* © 2013 RunOrg *)

val line : IInboxLine.t -> (#O.ctx,unit) Ohm.Run.t

val group : IAvatar.t -> IGroup.t -> (#O.ctx,unit) Ohm.Run.t
