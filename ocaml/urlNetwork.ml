(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let tag, def_tag = O.declare O.core "network/tag" (A.r A.string)
