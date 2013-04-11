(* © 2013 RunOrg *)

val schedule : mid:IMail.t -> uid:IUser.t -> act:IMail.Action.t option -> (#O.ctx,unit) Ohm.Run.t
