(* © 2013 RunOrg *)

open Ohm

include Fmt.Make(struct
  type json t = [ `Public "p" | `Normal "n" | `Private "r" ]
end)
