(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "core" name

let _page = 
  let mapping = [
    "header", Mk.ihtml (fun () -> GSplash.header) ;
    "footer", Mk.ihtml (fun () -> GSplash.footer) 
  ] in 
  let _fr     = load "404-fr" mapping `Html in 
  function `Fr -> _fr
  
let render render i18n = 
  let title = `label "404.title" in
  let body  = 
    to_html (_page (I18n.language i18n)) () i18n 
  in 
  render ~title:(I18n.get i18n title) ~body
