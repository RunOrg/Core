(* © 2012 RunOrg *)

val delete   : [`Remove] IItem.id -> unit O.run
val moderate : IItem.t -> [`Admin] MItem_common.source -> unit O.run
