(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let comments, def_comments = O.declare O.client "item/comments" (A.rr IItem.arg A.string) 
