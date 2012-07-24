(* © 2012 RunOrg *)

val get_if_exists : 'iid IInstance.id -> 'uid IUser.id -> (#Ohm.CouchDB.ctx, IAvatar.t option) Ohm.Run.t
val get : 'iid IInstance.id -> 'uid IUser.id -> (#Ohm.CouchDB.ctx, IAvatar.t) Ohm.Run.t
