(* © 2012 RunOrg *)

type t = 
  [ `Secret
  | `Website
  | `Draft
  | `Member  of Ohm.AdLib.gender 
  | `Admin   of Ohm.AdLib.gender
  | `Visitor of Ohm.AdLib.gender
  ] 

val css : t -> string
val label : t -> O.i18n
