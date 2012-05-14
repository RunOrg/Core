(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let core title html res =
  let! title = ohm $ AdLib.get title in 
  let! html  = ohm html in 
  return $ Action.page 
    (Html.print_page 
       ~js:["/public/jquery.min.js";"/public/jquery.json.min.js";Asset.js]
       ~css:[Asset.css] 
       ~title html) res
