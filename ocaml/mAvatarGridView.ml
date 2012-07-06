(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal
  
include Fmt.Make(struct

  type json t = 
    [ `Text "t"
    | `Date "d"
    | `Checkbox "c"
    | `DateTime "dt"
    | `Status "s"
    | `Age  "a"
    | `PickOne "po"
    | `Full "f"
    ]

end)
  

