(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util

let load name = MModel.Template.load "picker" name

let _async_section = 
  let _fr = load "asyncSection" [
    "code",  Mk.text (#code) ;
    "icon",  Mk.esc  (#icon) ;
    "title", Mk.esc  (#title) ;
  ] `Html in
  function `Fr -> _fr

let async_section ~url ~icon ~title ~i18n ctx = 
  to_html (_async_section (I18n.language i18n)) (object
    method icon  = icon
    method title = title
    method code  = JsBase.to_event (Js.lazyNext url) 
  end) i18n ctx

let _item =
  let _fr = load "item" [
    "code",  Mk.text (#code) ;
    "icon",  Mk.esc  (#icon) ;
    "title", Mk.esc  (#title) 
  ] `Html in
  function `Fr -> _fr

let item ~action ~icon ~title ~i18n ctx =
  to_html (_item (I18n.language i18n)) (object
    method icon  = icon
    method title = title
    method code  = JsBase.to_event action
  end) i18n ctx

let _picker = 
  let _fr = load "index" [
    "contents", Mk.html (#contents) 
  ] `Html in
  function `Fr -> _fr

let picker ~contents ~i18n ctx = 
  to_html (_picker (I18n.language i18n)) (object
    method contents = contents
  end) i18n ctx
