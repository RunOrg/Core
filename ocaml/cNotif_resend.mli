(* © 2013 RunOrg *)

val schedule : nid:INotif.t -> uid:IUser.t -> act:INotif.Action.t option -> (#O.ctx,unit) Ohm.Run.t
