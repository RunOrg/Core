(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let js ~deeplink = 
  BatList.filter_map identity [
    Some "/public/jquery.min.js" ;
    Some "/public/jquery.json.min.js" ;
    ( if deeplink then Some "/public/jquery.address.min.js" else None ) ;
    Some Asset.js
  ] 

let white_css = function None -> [] | Some wid ->
  [ "/theme." ^ IWhite.to_string wid ^ ".css" ] 

let splash title html res = 
  let! html = ohm $ Run.list_map identity html in 
  let  html = Html.concat html in
  return $ Action.page
    (Html.print_page
       ~js:(js false)
       ~css:[Asset.css]
       ~favicon:"/public/favicon.ico"
       ~title
       ~body_classes:["theme-splash"]
       html) res

let core ?(deeplink=false) owid title html res =
  let! title = ohm $ AdLib.get title in 
  let! html  = ohm html in 
  let  js    = js deeplink in 
  let  css = Asset.css :: white_css owid in 
  return $ Action.page 
    (Html.print_page 
       ~js
       ~css
       ~favicon:(ConfigWhite.favicon owid) 
       ~title html) res

