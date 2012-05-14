(* © 2012 RunOrg *)

open MVote_common

val read  : 'any t -> [`Read] t option O.run
val vote  : 'any t -> [`Vote] t option O.run
val admin : 'any t -> [`Admin] t option O.run
