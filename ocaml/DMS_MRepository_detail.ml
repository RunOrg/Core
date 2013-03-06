(* © 2013 RunOrg *)

open Ohm

include Fmt.Make(struct
  type json t = [ `Public | `Private ]
end)
