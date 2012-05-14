(* © 2012 MRunOrg *)

include Ohm.Fmt.FMT with type t =
  [ `Event | `Group | `Subscription | `Forum | `Poll | `Album | `Course ]
    
val all : t list
