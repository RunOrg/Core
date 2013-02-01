(* © 2013 RunOrg *)

val large : [`GetPic] IFile.id option -> (#Ohm.CouchDB.ctx,string) Ohm.Run.t
val small : [`GetPic] IFile.id option -> (#Ohm.CouchDB.ctx,string) Ohm.Run.t

val small_opt : [`GetPic] IFile.id option -> (#Ohm.CouchDB.ctx,string option) Ohm.Run.t
