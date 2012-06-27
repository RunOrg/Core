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

let tabs = 
  (function 
    | `Wall   -> "wall"
    | `Album  -> "album" 
    | `Votes  -> "votes"
    | `Folder -> "folder"
    | `People -> "people"), 
  (function
    | "wall"   -> `Wall
    | "album"  -> `Album
    | "votes"  -> `Votes
    | "folder" -> `Folder
    | "people" -> `People
    | other    -> `Wall)
    

