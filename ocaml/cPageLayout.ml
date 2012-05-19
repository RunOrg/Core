(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let core ?(deeplink=false) title html res =
  let! title = ohm $ AdLib.get title in 
  let! html  = ohm html in 

  let js = BatList.filter_map identity [
    Some "/public/jquery.min.js" ;
    Some "/public/jquery.json.min.js" ;
    ( if deeplink then Some "/public/jquery.address.min.js" else None ) ;
    Some Asset.js
  ] in

  return $ Action.page 
    (Html.print_page 
       ~js
       ~css:[Asset.css] 
       ~favicon:"/public/favicon.ico"
       ~title html) res
