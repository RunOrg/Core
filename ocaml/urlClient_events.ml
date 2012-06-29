(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

open UrlClient_common

let home,    def_home    = root "calendar"
let create,  def_create  = child def_home   "ev/create"
let options, def_options = child def_home   "ev/options"
let see,     def_see     = child def_create "event"
let admin,   def_admin   = child def_see    "ev/admin"
let edit,    def_edit    = child def_admin  "ev/edit"
let picture, def_picture = child def_admin  "ev/picture"
let people,  def_people  = child def_admin  "ev/people"
let access,  def_access  = child def_admin  "ev/access"

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
    

