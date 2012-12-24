(* © 2012 RunOrg *)

val update : 'a IInboxLine.id -> 'b IAvatar.id -> MInboxLine_common.Line.t -> (#O.ctx,unit) Ohm.Run.t
