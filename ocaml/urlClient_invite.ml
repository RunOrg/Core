(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

include UrlClient_common

let seg = 
  (function 
    | `ByEmail -> "e"
    | `ByName  -> "n" 
    | `ByGroup -> "g"), 
  (function
    | "e"   -> `ByEmail
    | "n"   -> `ByName
    | "g"   -> `ByGroup
    | other -> `ByGroup)
