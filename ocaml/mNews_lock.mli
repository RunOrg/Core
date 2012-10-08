(* © 2012 RunOrg *)

val grab : IUser.t -> (#Ohm.CouchDB.ctx,< last : float ; recent : bool ; locked : bool >) Ohm.Run.t
val release : IUser.t -> (#Ohm.CouchDB.ctx,unit) Ohm.Run.t
