(* © 2013 RunOrg *)

type t = <
  time : string ;
  server : string ;
  url : string ;
  user : IUser.t option ;
  exn : string ;
  backtrace : string
>

module Signals : sig

  val on_create : (t, unit O.run) Ohm.Sig.channel

end

val on_frontend : 
     server:string
  -> url:string
  -> user:IUser.t option
  -> exn:exn
  -> unit O.run

