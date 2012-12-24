(* © 2012 RunOrg *)

type t = <
  firstname : string ; 
  initials  : string ; 
  body      : string ;
  picture   : string option ; 
  org       : string option ; 
>

val set : 'a IUser.id -> t -> (#O.ctx,unit) Ohm.Run.t
val get : 'a IUser.id -> (#O.ctx,t option) Ohm.Run.t

val all : unit -> (#O.ctx,t list) Ohm.Run.t 
