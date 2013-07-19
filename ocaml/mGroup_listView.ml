(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

include Fmt.Make(struct
  type json t = [ `Viewers "v" | `Registered "r" | `Managers "m" ] 
end)

