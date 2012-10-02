(* © 2012 RunOrg *)

open Ohm

type who = [ `user of (Id.t * IAvatar.t) | `preconfig ]

module T = struct
  type json t = {
    who : [ `user of (Id.t * IAvatar.t) | `preconfig ]
  }
end
include T
include Fmt.Extend(T)

let info ~who = { who = who }

(* Hack around the block to define the signature appropriately... *)
type info = t = { who : who }
module type F = Fmt.FMT with type t = info


