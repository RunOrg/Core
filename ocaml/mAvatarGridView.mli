(* © 2013 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  [ `Text
  | `Date
  | `DateTime
  | `Status
  | `Checkbox
  | `Age 
  | `PickOne
  | `Full
  ]

