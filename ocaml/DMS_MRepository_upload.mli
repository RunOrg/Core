(* © 2013 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  [ `Viewers | `List of IAvatar.t list ] 
