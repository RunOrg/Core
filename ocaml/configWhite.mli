(* © 2012 RunOrg *)

val test : IWhite.t
val ffbad : IWhite.t
val fscf : IWhite.t

type t = 
  [ `RunOrg
  | `Test
  | `FFBAD
  | `FSCF
  ]

val represent : IWhite.t option -> t 

val all : IWhite.t list

val domain : IWhite.t -> string

val white : string -> IWhite.t option

val slice_domain : string -> string option * IWhite.t option  

val name : IWhite.t option -> string
val the : IWhite.t option -> string
val of_the : IWhite.t option -> string
val email : IWhite.t option -> string
val no_reply : IWhite.t option -> string
val short : IWhite.t option -> string

val favicon : IWhite.t option -> string

val default_vertical : IWhite.t option -> IVertical.t 
