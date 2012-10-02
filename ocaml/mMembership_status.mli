(* © 2012 RunOrg *)

include Ohm.Fmt.FMT with type t =
  [ `Unpaid
  | `Pending
  | `Invited
  | `NotMember
  | `Member
  | `Declined ] 
