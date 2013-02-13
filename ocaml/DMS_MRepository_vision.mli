(* © 2013 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  [ `Normal | `Private of IAvatarSet.t list ] 
