(* © 2012 RunOrg *)

type t = 
  [ `Secret
  | `Website
  | `Draft
  | `Member  of Ohm.AdLib.gender 
  | `Admin   of Ohm.AdLib.gender
  | `Visitor of Ohm.AdLib.gender
  | `GroupMember of Ohm.AdLib.gender
  | `Unpaid      of Ohm.AdLib.gender
  | `Declined    of Ohm.AdLib.gender
  | `Invited     of Ohm.AdLib.gender
  | `Pending     of Ohm.AdLib.gender
  ] 

val css : t -> string
val label : t -> O.i18n
