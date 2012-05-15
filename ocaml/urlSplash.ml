(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let index, def_index = O.declare O.core "" (A.n A.string)
