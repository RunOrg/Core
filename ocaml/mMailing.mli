(* © 2013 RunOrg *)

val create : mailing:string -> email:string -> name:string -> url:string -> (#O.ctx,Ohm.Id.t) Ohm.Run.t

val click : Ohm.Id.t -> (#O.ctx, (string * string) option) Ohm.Run.t
