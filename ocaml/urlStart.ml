(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let home, def_home = O.declare O.core "start" (A.o IVertical.arg) 
let free, def_free = O.declare O.core "start/free" A.none
