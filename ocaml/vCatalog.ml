(* © 2012 Runorg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "catalog" end)

module IndexBoxVertical = Loader.Html(struct
  type t = <
    title   : I18n.text ;
    summary : string ;  
    details : string ;
    start   : string 
  > ;;
  let source  _ = "box/verticals"
  let mapping _ = [
    "title",   Mk.trad (#title) ;
    "summary", Mk.str  (#summary) ;
    "details", Mk.esc  (#details) ;
    "start",   Mk.esc  (#start) ;
  ] 
end)

module IndexBox = Loader.Html(struct
  type t = <
    id        : string ;
    label     : I18n.text ;
    verticals : IndexBoxVertical.t list
  > ;;
  let source  _ = "box"
  let mapping l = [
    "id",        Mk.esc  (#id) ;
    "label",     Mk.trad (#label) ;
    "verticals", Mk.list (#verticals) (IndexBoxVertical.template l)
  ]
end)

module Index = Loader.JsHtml(struct
  type t = IndexBox.t list
  let source    = function `Fr -> "index-fr"
  let mapping l = [
    "header", Mk.ihtml (fun _ -> GSplash.header) ;
    "footer", Mk.ihtml (fun _ -> GSplash.footer) ;
    "list", Mk.list identity (IndexBox.template l) 
  ] 
  let script  l = []
end)

module Image = Loader.Html(struct
  type t = < image : string ; text : string > ;;
  let source  _ = "page/slideshow/images"
  let mapping _ = [
    "url",  Mk.esc (#image) ;
    "text", Mk.esc (#text)
  ]
end)

module Slideshow = Loader.Html(struct
  type t = Image.t list ;;
  let source  _ = "page/slideshow"
  let mapping l = [ "images", Mk.list identity (Image.template l) ]
end)

module SubVertical = Loader.Html(struct
  type t = < url : string ; label : I18n.text > ;;
  let source  _ = "page/subverticals/list"
  let mapping _ = [
    "url",   Mk.esc  (#url) ;
    "label", Mk.trad (#label) ;
  ]
end)

module SubVerticalList = Loader.Html(struct
  type t = SubVertical.t list 
  let source  _ = "page/subverticals"
  let mapping l = [ "list", Mk.list identity (SubVertical.template l) ]
end)

module Features = Loader.Html(struct
  type t = string
  let source  _ = "page/features"
  let mapping _ = [ "body", Mk.str identity ]
end)

module Subtitle = Loader.Html(struct
  type t = string
  let source  _ = "page/subtitle"
  let mapping _ = [ "text", Mk.str identity ]
end)

module YouCan = Loader.Html(struct
  type t = string
  let source  _ = "page/you-can"
  let mapping _ = [ "text", Mk.str identity ]
end)

module Pricing = Loader.Html(struct
  type t = string
  let source  _ = "page/pricing"
  let mapping _ = [ "text", Mk.str identity ]
end)

module HelpUs = Loader.Html(struct
  type t = unit
  let source    = function `Fr -> "help-us-fr"
  let mapping _ = []
end)

module Page = Loader.Html(struct
  type t = <
    slideshow : Image.t list option ;
    subverticals : SubVertical.t list option ;
    features : string list ;
    description : string ;
    name : I18n.text ;
    subtitle : string option ;
    pricing : string option ;
    youcan : string option ;
    create : string 
  > ;;
  let source  _ = "page"
  let mapping l = [
    "header",       Mk.ihtml  (fun _ -> GSplash.header) ;
    "footer",       Mk.ihtml  (fun _ -> GSplash.footer) ;
    "slideshow",    Mk.sub_or (#slideshow)    (Slideshow.template l)       (Mk.empty) ;
    "subverticals", Mk.sub_or (#subverticals) (SubVerticalList.template l) (Mk.empty) ;
    "features",     Mk.list   (#features)     (Features.template l) ;
    "description",  Mk.str    (#description) ;
    "name",         Mk.trad   (#name) ;
    "subtitle",     Mk.sub_or (#subtitle)     (Subtitle.template l)        (Mk.empty) ;
    "you-can",      Mk.sub_or (#youcan)       (YouCan.template l)          (Mk.empty) ; 
    "pricing",      Mk.sub_or (#pricing)      (Pricing.template l)         (Mk.empty) ;
    "create-url",   Mk.esc    (#create) ;
    "help-us",      Mk.sub    (fun x -> ()) (HelpUs.template l)
  ]      
end)
