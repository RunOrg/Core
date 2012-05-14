(* © 2012 MRunOrg *)

type t = <
  tests : (string * bool) list ;
  paths : (string * (string * <
    view  : string ;
    title : string
  >) list) list
> ;;

val config : t

val test_of_session : admin:bool -> string -> string
