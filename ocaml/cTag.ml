(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let prepare owid tag = object
  method url  = Action.url UrlNetwork.tag owid (String.lowercase tag) 
  method text = tag
end
