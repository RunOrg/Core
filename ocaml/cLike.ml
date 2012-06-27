(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render likes count = 
  Asset_Like_Button.render (object
    method count = count
    method likes = likes
  end)

 
