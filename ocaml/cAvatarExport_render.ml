(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let cell json eval = return (Json.serialize json)
