(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "moreActions" name

type item = <
  action : [`Go of string | `Do of JsCode.t ] ;
  icon : string ;
  text : I18n.text
> ;;

let _item = 
  let _any = load "item" [
    "icon",   Mk.esc  (#icon) ;
    "text",   Mk.trad (#text) ;
    "action", Mk.text (fun x -> match x # action with 
      | `Go url -> View.str "href=\"" |- View.esc url |- View.str "\""
      | `Do js  -> View.str "href=\"javascript:void(0)\" onclick=\"" |- JsBase.to_event js |- View.str "\"") ;
  ] `Html in
  function `Fr -> _any

let _component = 
  let _fr = load "component" [
    "text", Mk.trad (#text) ;
    "actions", Mk.list (#actions) (_item `Fr) 
  ] `Html in
  function `Fr -> _fr

let component ~text ~actions ~i18n ctx = 
  if actions = [] then ctx else
    to_html (_component (I18n.language i18n)) (object
      method text    = text
      method actions = (actions : item list)
    end) i18n ctx
