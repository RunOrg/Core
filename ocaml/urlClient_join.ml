(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let ajax, def_ajax = O.declare O.client "join/ajax" (A.r IEntity.arg)
