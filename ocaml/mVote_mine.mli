(* © 2012 RunOrg *)

open MVote_common

val set : [`Vote] vote -> [`IsSelf] IAvatar.id -> int list -> bool O.run
val get : [`Vote] vote -> [`IsSelf] IAvatar.id -> int list option O.run

