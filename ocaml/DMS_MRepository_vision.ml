(* © 2013 RunOrg *)

open Ohm

include Fmt.Make(struct
  type json t = [ `Normal "n" | `Private "r" of IAvatarSet.t list ]
end)
