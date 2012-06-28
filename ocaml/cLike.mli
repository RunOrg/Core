(* © 2012 RunOrg *)

type what 

val render : what -> bool -> int -> Ohm.Html.writer O.run

val item : 'any CAccess.t -> [`Read] IItem.id -> what
