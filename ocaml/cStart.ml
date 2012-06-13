(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlStart.def_home begin fun req res -> 
  return res
end
