(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let root, def_root = O.declare O.core "me" (A.n A.string)

let account = Action.url root () ["account"]
let network = Action.url root () ["network"]
let news    = Action.url root () ["news"]
