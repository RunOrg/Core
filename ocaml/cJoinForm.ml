(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let box access entity inner = 
  inner (return ignore) 
