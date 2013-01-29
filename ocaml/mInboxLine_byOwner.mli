(* © 2012 RunOrg *)

val get_or_create : 'any IInboxLineOwner.id -> (#O.ctx,IInboxLine.t) Ohm.Run.t
val get : 'any IInboxLineOwner.id -> (#O.ctx,IInboxLine.t option) Ohm.Run.t
