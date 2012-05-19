(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let root, def_root = O.declare O.core "me" A.none
let ajax, def_ajax = O.declare O.core "me/ajax" (A.n A.string)

let url list = 
  Action.url root () () ^ "/#/" ^ String.concat "/" 
    (List.map Netencoding.Url.encode list)

let account = url ["account"]
let network = url ["network"]
let news    = url ["news"]
