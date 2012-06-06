(* © 2012 RunOrg *)

val name : [<`Admin|`View] MEntity.t -> (O.i18n #Ohm.AdLib.ctx, string) Ohm.Run.t
val pic_large : [<`Admin|`View] MEntity.t -> (#Ohm.CouchDB.ctx, string) Ohm.Run.t
