(* © 2012 RunOrg *)

module Data : sig
  type t = {
    vertical : IVertical.t ;
    name     : string ;
    desc     : string ;
    key      : string 
  }
end

val set_vertical :
     IFunnel.t
  -> IVertical.t
  -> unit O.run

val set_info :
     IFunnel.t
  -> string
  -> string
  -> string
  -> unit O.run

val get : IFunnel.t -> Data.t option O.run
val default : Data.t
