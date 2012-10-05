(* © 2012 RunOrg *)

val test : IWhite.t

val all : IWhite.t list

val domain : IWhite.t -> string

val slice_domain : string -> string option * IWhite.t option  
