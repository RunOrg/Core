(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let item, def_item = O.declare O.client "like/item" (A.rr IItem.arg A.string) 
