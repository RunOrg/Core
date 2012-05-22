(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let website, def_website = O.declare O.client "" (A.n A.string)
let root,    def_root    = O.declare O.client "intranet" A.none

let intranet key list = 
  OhmBox.url (Action.url root key ()) list

let home    key = intranet key ["home"] 
let members key = intranet key ["members"] 
let forums  key = intranet key ["forums"] 
let events  key = intranet key ["events"]
