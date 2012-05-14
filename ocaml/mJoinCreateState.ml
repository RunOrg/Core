(* © 2012 RunOrg *)

open Ohm

include Fmt.Make(struct
  type json t = [ `ignore | `invite | `add ]
end)

