(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MNews_common

let create t = 
  let time = Unix.gettimeofday () in
  create_backoffice ~payload:(`login t) ~time
