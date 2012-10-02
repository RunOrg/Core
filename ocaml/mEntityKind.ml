(* © 2012 RunOrg *)

open Ohm
open Ohm.Util

include Fmt.Make(struct
  type json t = [ `Event | `Group | `Subscription | `Forum | `Poll | `Album | `Course ] 
end)
  
let all = [ `Group ; `Event ; `Subscription ; `Forum ; `Poll ; `Album ; `Course ]
