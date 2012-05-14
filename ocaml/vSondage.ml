(* © 2012 RunOrg *)

open Ohm
open Ohm.Template

let load name = MModel.Template.load "sondage" name

let render = 
  let _render = 
    let _fr = 
      load "index-fr" [
      "ajax-url",  Mk.esc (#ajax) ;
      "final-url", Mk.esc (#final) ;
    ] `Html in
    function `Fr -> _fr
  in
  fun ~ajax ~final ~i18n ctx ->
    let template = _render (I18n.language i18n) in 
    let data = object
      method ajax  = ajax
      method final = final
    end in 
    to_text template data i18n ctx

let thanks = 
  let _thanks = 
    let _fr = load "thanks-fr" [] `Html in
    function `Fr -> _fr
  in
  fun ~i18n ctx ->
    let template = _thanks (I18n.language i18n) in
    let data = () in
    to_text template data i18n ctx
