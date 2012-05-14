(* © 2012 MRunOrg *)

open Ohm

include Fmt.Make(struct
  type json t = [`Admin "own" | `Token "mbr" | `Contact "ctc" ]
end)

