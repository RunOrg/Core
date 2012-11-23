(* © 2012 RunOrg *)

type who = [ `user of (Ohm.Id.t * IAvatar.t) | `preconfig ]

(* This type is a hack... *)
type info = { who : who }

module type F = Ohm.Fmt.FMT with type t = info
include F

val info : who:who -> t

val self : ?key:Ohm.Id.t -> [`IsSelf] IAvatar.id -> info 
