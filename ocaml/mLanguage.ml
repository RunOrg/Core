(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

include Fmt.Make(struct
  type json t = 
    [ `FR ] 
end)

