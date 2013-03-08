(* © 2013 RunOrg *)

open Ohm

include Fmt.Make(struct
  type json t = [ `Viewers "v" | `List "l" of IAvatar.t list ]
end)
