(* © 2012 RunOrg *)

val delete   : [`Remove] IItem.id -> unit O.run
val moderate : IItem.t -> ([`Unknown] MItem_common.source -> [`Admin] MItem_common.source option O.run) -> unit O.run
