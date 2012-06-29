(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let comments, def_comments = O.declare O.client "item/comments" (A.rr IItem.arg A.string) 
let remove, def_remove = O.declare O.client "item/remove" (A.rr IItem.arg A.string) 
