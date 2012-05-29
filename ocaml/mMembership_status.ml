(* © 2012 RunOrg *)

open Ohm

include Ohm.Fmt.Make(struct
  type json t = 
    [ `Unpaid
    | `Pending
    | `Invited
    | `NotMember
    | `Member 
    | `Declined ] 
end)
