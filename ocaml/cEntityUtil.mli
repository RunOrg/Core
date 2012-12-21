(* © 2012 RunOrg *)

val name : [<`Admin|`View] MEntity.t -> (O.i18n #Ohm.AdLib.ctx, string) Ohm.Run.t
val data : [<`Admin|`View] MEntity.t -> (string * Ohm.Json.t) list O.run
val public_forum : [<`Admin|`View] MEntity.t -> bool 
val private_forum : [<`Admin|`View] MEntity.t -> bool 
