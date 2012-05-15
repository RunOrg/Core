(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let website, def_website = O.declare O.client "" (A.n A.string)
let root,    def_root    = O.declare O.client "intranet" (A.n A.string)

let home    key = Action.url root key ["home"] 
let members key = Action.url root key ["members"] 
let forums  key = Action.url root key ["forums"] 
let events  key = Action.url root key ["events"]
