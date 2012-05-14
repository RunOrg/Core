(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "directory" name

module Loader = MModel.Template.MakeLoader(struct let from = "directory" end)

type item = <
  url     : string ;
  name    : string ;
  picture : string ;
  status  : VStatus.t
> ;;

let _item = 
  let _fr = load "item" [
    "name",         Mk.esc  (#name) ;
    "status-class", Mk.esc  (#status |- VStatus.css_class) ;
    "status-name",  Mk.trad (#status |- VStatus.label) ;
    "image-url",    Mk.esc  (#picture) ;
    "url",          Mk.esc  (#url) ;
  ] `Html in
  function `Fr -> _fr

let _more_link = 
  let _fr = load "more-link" [
    "onclick", Mk.text identity
  ] `Html in
  function `Fr -> _fr

let _empty = VCore.empty VIcon.Large.book_addresses (`label "directory.empty")

let _more = 
  let _fr = load "more" [  
    "list", Mk.list_or (#list) (_item `Fr) _empty ;
    "more", Mk.sub_or  (#more) (_more_link `Fr) (Mk.empty) ;
  ] `Html  in
  function `Fr -> _fr

let more ~more ~list ~i18n ctx = 
  to_html (_more (I18n.language i18n)) (object
    method list = (list : item list) 
    method more = more
  end) i18n ctx
    
let _page = 
  let _fr = load "page" [
    "list", Mk.list_or (#list) (_item `Fr) _empty ;
    "more", Mk.sub_or  (#more) (_more_link `Fr) (Mk.empty) ;
  ] `Html  in
  function `Fr -> _fr
    
let page ~more ~list ~i18n ctx = 
  to_html (_page (I18n.language i18n)) (object
    method list = (list : item list) 
    method more = more
  end) i18n ctx

module FullPageSearch = Loader.Html(struct
  type t = unit
  let source  _ = "full-page/search"
  let mapping _ = []
end)
    
module FullPage = Loader.Html(struct  
  type t = <
    access : VAccessFlag.access option ;
    list   : item list ;
    more   : View.Context.text View.t option ;
    search : I18n.html ;
  > ;;
  let source  _ = "full-page"
  let mapping l = [
    "access", Mk.ihtml  (#access |- VAccessFlag.render) ;
    "list",   Mk.list   (#list) (_item l) ;
    "more",   Mk.sub_or (#more) (_more_link l) (Mk.empty) ;
    "search", Mk.ihtml  (#search)
  ] 
end)

module AdminPage = Loader.Html(struct  
  type t = <
    group  : string ;
    add    : string ;
    list   : item list ;
    more   : View.Context.text View.t option ;
  > ;;
  let source  _ = "admin-page"
  let mapping l = [
    "group",  Mk.esc    (#group) ;
    "add",    Mk.esc    (#add) ;
    "list",   Mk.list   (#list) (_item l) ;
    "more",   Mk.sub_or (#more) (_more_link l) (Mk.empty) ;
  ] 
end)
