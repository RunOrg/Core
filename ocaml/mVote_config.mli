(* © 2012 RunOrg *)

open MVote_common

type t = <
  closed_on : float option ;
  opened_on : float option ;
> ;;

val create : ?closed:float -> ?opened:float -> unit -> t 

val get   : 'any vote -> t  
val set   : [`Admin] vote -> t -> unit O.run
val close : [`Admin] vote -> unit O.run
