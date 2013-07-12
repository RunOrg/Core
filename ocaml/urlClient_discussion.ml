(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

open UrlClient_common

module Inbox = UrlClient_inbox

let def_home = Inbox.def_home

let create,   def_create   = child def_home     "ds/create"
let see,      def_see      = child def_create   "discussion"
let admin,    def_admin    = child def_see      "ds/admin"
let edit,     def_edit     = child def_admin    "ds/edit"
let delete,   def_delete   = child def_admin    "ds/delete"

