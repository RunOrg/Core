(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let login, def_login = O.declare O.secure "login" (A.o IInstance.arg)
