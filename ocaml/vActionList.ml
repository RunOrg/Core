(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "actionList" name

type action = <
 js    : JsCode.t ;
 label : I18n.text ;
 icon  : string  
> ;;

let _item = 
  let _fr = load "item" [
    "label", Mk.trad (#label) ;
    "click", Mk.text (#js |- JsBase.to_event) ;
    "icon",  Mk.esc  (#icon)
  ] `Html in
  function `Fr -> ( _fr : (action, View.Context.box) Template.t )

let _list = 
  let _fr = load "list" [
    "list", Mk.list (#list) (_item `Fr)
  ] `Html in
  function `Fr -> _fr

let list ~list ~i18n ctx = 
  if list = [] then ctx else
    to_html (_list (I18n.language i18n)) (object 
      method list = list
    end) i18n ctx

      
