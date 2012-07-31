(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let home,   def_home   = O.declare O.core "admin" A.none
let active, dev_active = O.declare O.core "admin/active" A.none
