(* © 2012 RunOrg *) 

open Ohm 
open Ohm.Universal
open BatPervasives

let () = UrlClient.def_newhere begin fun req res ->
  return (Action.json [ "ok", Json.Bool true ] res)
end
