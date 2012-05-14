(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "contact" end)

module ConfirmedItem = Loader.Html(struct
  type t = <
    time    : float ;
    url     : string ;
    picture : string ;
    name    : string ;
    status  : VStatus.t
  >
  let source  _ = "confirmed-list/items"
  let mapping _ = [
    "name",         Mk.esc   (#name) ;
    "status-class", Mk.esc   (#status |- VStatus.css_class) ;
    "status-name",  Mk.trad  (#status |- VStatus.label) ;
    "image-url",    Mk.esc   (#picture) ;
    "url",          Mk.esc   (#url) ;
    "time",         Mk.itext (#time |- VDate.render) ;
  ]
end)

module ConfirmedMore = Loader.Html(struct
  type t = View.text
  let source  _ = "confirmed-list/more" 
  let mapping _ = [
    "onclick", Mk.text identity
  ]
end)

module More = Loader.Html(struct
  type t = < 
    list : ConfirmedItem.t list ;
    more : View.text option
  > ;;
  let source  _ = "confirmed-list" 
  let mapping l = [
    "items", Mk.list   (#list) (ConfirmedItem.template l) ;
    "more",  Mk.sub_or (#more) (ConfirmedMore.template l) (Mk.empty)
  ] 
end)

module Page = Loader.Html(struct
  type t = < 
    list   : ConfirmedItem.t list ;
    access : VAccessFlag.access option ;
    more   : View.text option
  > ;;
  let source  _ = "confirmed" 
  let mapping l = [
    "items",  Mk.list   (#list) (ConfirmedItem.template l) ;
    "more",   Mk.sub_or (#more) (ConfirmedMore.template l) (Mk.empty) ;
    "access", Mk.ihtml  (#access |- VAccessFlag.render)
  ] 
end)
