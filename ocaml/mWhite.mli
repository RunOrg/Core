(* © 2012 RunOrg *)

module Data : sig
  type t = {
    theme : string ;
    name  : string ;
  }
end

val get : IWhite.t -> Data.t option O.run
val theme : Data.t -> string 
val name  : Data.t -> string
