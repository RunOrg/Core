(* © 2012 RunOrg *)

module Data : sig
  type t = <
    title  : string ;
    input  : string ;
    clean  : string ;
    links  : string list ;
    tags   : string list ;
    shown  : bool ;
    format : int
  >
end

val get : IHelp.t -> Data.t option O.run

val update : 
     IHelp.t
  -> title:string
  -> input:string
  -> links:string list
  -> tags:string list
  -> shown:bool
  -> unit O.run
