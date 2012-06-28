(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let post, def_post = O.declare O.client "comment/post" (A.rr IItem.arg A.string) 
