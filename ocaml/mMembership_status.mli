(* © 2012 MRunOrg *)

include Ohm.Fmt.FMT with type t =
  [ `Unpaid
  | `Pending
  | `Invited
  | `NotMember
  | `Member
  | `Declined ] 
