(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

open UrlClient_common

let home,   def_home = root "forums"
let create, def_create = child def_home   "frm/create"
let see,    def_see    = child def_create "discuss"
let admin,  def_admin  = child def_see    "frm/admin"
let edit,   def_edit   = child def_admin  "frm/edit"
let people, def_people = child def_admin  "frm/people"

let tabs = 
  (function 
    | `Wall   -> "wall"
    | `Album  -> "album" 
    | `Folder -> "folder"
    | `People -> "people"), 
  (function
    | "wall"   -> `Wall
    | "album"  -> `Album
    | "folder" -> `Folder
    | "people" -> `People
    | other    -> `Wall)
