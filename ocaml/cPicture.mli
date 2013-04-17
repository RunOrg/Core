(* © 2013 RunOrg *)

val large : [`GetPic] IOldFile.id option -> (#Ohm.CouchDB.ctx,string) Ohm.Run.t
val small : [`GetPic] IOldFile.id option -> (#Ohm.CouchDB.ctx,string) Ohm.Run.t

val small_opt : [`GetPic] IOldFile.id option -> (#Ohm.CouchDB.ctx,string option) Ohm.Run.t
