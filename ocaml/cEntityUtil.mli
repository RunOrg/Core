(* © 2012 RunOrg *)

val name : [<`Admin|`View] MEntity.t -> (O.i18n #Ohm.AdLib.ctx, string) Ohm.Run.t
val pic_large : [<`Admin|`View] MEntity.t -> (#Ohm.CouchDB.ctx, string) Ohm.Run.t
val pic_small_opt : [<`Admin|`View] MEntity.t -> (#Ohm.CouchDB.ctx, string option) Ohm.Run.t
val desc : [<`Admin|`View] MEntity.t -> string option O.run
val data : [<`Admin|`View] MEntity.t -> (string * Ohm.Json.t) list O.run
val public_forum : [<`Admin|`View] MEntity.t -> bool 
