(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let prepare tag = object
  method url  = Action.url UrlNetwork.tag () (String.lowercase tag) 
  method text = tag
end
