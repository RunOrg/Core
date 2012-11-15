(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

open UrlClient_common

let avatars, def_avatars = O.declare O.client "search/avatar" A.none
