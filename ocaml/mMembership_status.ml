(* © 2012 MRunOrg *)

include Ohm.Fmt.Make(struct
  type json t = 
    [ `Unpaid
    | `Pending
    | `Invited
    | `NotMember
    | `Member 
    | `Declined ] 
end)
