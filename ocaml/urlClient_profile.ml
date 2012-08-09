(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

open UrlClient_common

let home,    def_home    = child UrlClient_members.def_home "profile"

let tabs = 
  (function 
    | `Groups   -> "groups"
    | `Forms    -> "forms" 
    | `Messages -> "messages"
    | `Images   -> "images"
    | `Files    -> "files"), 
  (function
    | "forms"    -> `Forms
    | "messages" -> `Messages
    | "images"   -> `Images
    | "files"    -> `Files
    | other      -> `Groups)
    

