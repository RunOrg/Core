(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let root, def_root = O.declare O.core "me" (A.n A.string)

let url list = Action.url root () ("#" :: list) 

let account = url ["account"]
let network = url ["network"]
let news    = url ["news"]
