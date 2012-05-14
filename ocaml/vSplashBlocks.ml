(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "splash-blocks" end)

module Facebook = Loader.Html(struct
  type t = unit
  let source  _ = "facebook"
  let mapping _ = []
end)

module TitleProduct = Loader.Html(struct
  type t = <
    selected : bool ;
    name     : string ;
    url      : string 
  > ;;
  let source  _ = "title/product"
  let mapping _ = [
    "selected", Mk.str (fun x -> if x # selected then " class=\"-selected\"" else "") ;
    "name",     Mk.esc (#name) ;
    "url",      Mk.esc (#url) 
  ]
end)

module Title = Loader.Html(struct
  type t = <
    home     : string ;
    products : TitleProduct.t list 
  > ;;
  let source  _ = "title"
  let mapping l = [
    "home",    Mk.esc  (#home) ;
    "product", Mk.list (#products) (TitleProduct.template l) ;
  ]
end)

module PageHead = Loader.Html(struct
  type t = <
    title : string ;
    text  : string 
  > ;;
  let source  _ = "pagehead"
  let mapping _ = [
    "title", Mk.esc (#title) ;
    "text",  Mk.str (#text |- VText.format)
  ] 
end)

module SubmenuItem = Loader.Html(struct
  type t = <
    selected : bool ;
    name     : string ;
    url      : string 
  > ;;
  let source  _ = "submenu/item"
  let mapping _ = [
    "selected", Mk.str (fun x -> if x # selected then " class=\"-selected\"" else "") ;
    "name",     Mk.esc (#name) ;
    "url",      Mk.esc (#url) 
  ]
end)
 
module SubmenuTryNow = Loader.Html(struct
  type t = <
    name     : string ;
    url      : string 
  > ;;
  let source  _ = "submenu/trynow"
  let mapping _ = [
    "name",     Mk.esc (#name) ;
    "url",      Mk.esc (#url) 
  ]
end)
 
module Submenu = Loader.Html(struct
  type t = <
    items  : SubmenuItem.t list ;
    trynow : SubmenuTryNow.t option 
  > ;;
  let source  _ = "submenu"
  let mapping l = [
    "item",   Mk.list   (#items)  (SubmenuItem.template l) ;
    "trynow", Mk.sub_or (#trynow) (SubmenuTryNow.template l) (Mk.empty) 
  ]
end)

module Composite = Loader.Html(struct
  type t = <
    kind  : [`LLR | `LR | `LRR ] ;
    left  : I18n.html ;
    right : I18n.html
  > ;;
  let source  _ = "composite"
  let mapping l = [
    "kind",  Mk.str (#kind |- (function `LLR -> "-LLR" | `LR -> "-LR" | `LRR -> "-LRR")) ;
    "left",  Mk.ihtml (#left) ;
    "right", Mk.ihtml (#right) 
  ]
end)

module BulletItem = Loader.Html(struct
  type t = string * string
  let source  _ = "bullets/bullet"
  let mapping _ = [
    "number", Mk.esc fst ;
    "text",   Mk.esc snd
  ]
end)

module Bullet = Loader.Html(struct
  type t = <
    title    : string ;
    subtitle : string ;
    ordered  : bool ;
    items    : string list
  > ;;
  let source  _ = "bullets"
  let mapping l = [
    "title",    Mk.esc (#title) ;
    "subtitle", Mk.esc (#subtitle) ;
    "bullet",   Mk.list (fun x -> 
      if x # ordered then  
	BatList.mapi (fun i x -> (string_of_int (i+1),x)) (x # items)
      else
	List.map (fun x -> (" ",x)) (x # items)) (BulletItem.template l)
  ]
end)

module PrideSubtitle = Loader.Html(struct
  type t = string
  let source  _ = "pride/subtitle"
  let mapping _ = [ "subtitle", Mk.esc identity ]
end)

module PrideLink = Loader.Html(struct
  type t = string * string
  let source  _ = "pride/link"
  let mapping _ = [
    "url",  Mk.esc fst ;
    "text", Mk.esc snd
  ]
end) 

module Pride = Loader.Html(struct
  type t = <
    title    : string ;
    subtitle : PrideSubtitle.t option ;
    text     : string ;
    link     : PrideLink.t option 
  > ;;
  let source  _ = "pride"
  let mapping l = [
    "title",    Mk.esc (#title) ;
    "subtitle", Mk.sub_or (#subtitle) (PrideSubtitle.template l) Mk.empty ;
    "text",     Mk.str (#text |- VText.format) ;
    "link",     Mk.sub_or (#link) (PrideLink.template l) Mk.empty 
  ]
end)

module ImageCopyright = Loader.Html(struct
  type t = <
    url  : string ;
    name : string 
  > ;;
  let source  _ = "image/copyright"
  let mapping _ = [
    "url",  Mk.esc (#url) ;
    "name", Mk.esc (#name) 
  ] 
end)

module Image = Loader.Html(struct
  type t = <
    url : string ;
    copyright : ImageCopyright.t option 
  > 
  let source  _ = "image"
  let mapping l = [
    "url",       Mk.esc (#url) ;
    "copyright", Mk.sub_or (#copyright) (ImageCopyright.template l) Mk.empty 
  ]
end)

module Ribbon = Loader.Html(struct
  type t = I18n.html
  let source  _ = "ribbon"
  let mapping _ = [ "inner", Mk.ihtml identity ]
end)

module Important = Loader.Html(struct
  type t = <
    title : string ;
    text  : string 
  > ;;
  let source  _ = "important"
  let mapping _ = [
    "title", Mk.esc (#title) ;
    "text",  Mk.str (#text |- VText.format)
  ] 
end)

module VideoSource = Loader.Html(struct
  type t = <
    src  : string ;
    mime : string
  > ;;
  let source  _ = "video/source"
  let mapping _ = [
    "src",  Mk.esc (#src) ;
    "mime", Mk.esc (#mime) 
  ]
end)

module Video = Loader.Html(struct
  type t = <
    height  : int ;
    poster  : string ;
    sources : VideoSource.t list 
  > ;;
  let source  _ = "video"
  let mapping l = [
    "height",  Mk.int  (#height) ;
    "poster",  Mk.esc  (#poster) ;
    "source",  Mk.list (#sources) (VideoSource.template l)
  ]
end)

module Youtube = Loader.Html(struct
  type t = string
  let source  _ = "youtube"
  let mapping _ = [ "source", Mk.esc identity ] 
end)

module Price = Loader.Html(struct
  type t = <
    title    : string ;
    subtitle : string ;
    text     : string
  > ;;
  let source  _ = "price"
  let mapping _ = [
    "title",    Mk.esc (#title) ;
    "subtitle", Mk.esc (#subtitle) ;
    "text",     Mk.esc (#text)
  ]
end) 

module RecommendItem = Loader.Html(struct
  type t = <
    quote : string ;
    who   : string ;
    org   : string ;
    last  : bool
  > ;;
  let source  _ = "recommend/item"
  let mapping _ = [
    "quote", Mk.esc (#quote) ;
    "who",   Mk.esc (#who) ;
    "org",   Mk.esc (#org) ;
    "last",  Mk.str (#last |- (function true -> " -last" | false -> ""))
  ]
end)

module Recommend = Loader.Html(struct 
  type t = <
    title : string ; 
    subtitle : string ;
    items : <
      quote : string ;
      who   : string ;
      org   : string
    > list
  > ;;
  let source  _ = "recommend"
  let mapping l = [
    "title",    Mk.esc (#title) ;
    "subtitle", Mk.esc (#subtitle) ;
    "item",     Mk.list
      (#items |- BatList.mapi (fun i item -> (object
	method quote = item # quote
	method who   = item # who
	method org   = item # org
	method last  = i mod 3 = 2
      end)))
      (RecommendItem.template l)
  ]
end)

module FooterItem = Loader.Html(struct
  type t = <
    url  : string ;
    name : string ;
  > ;;
  let source    = function `Fr -> "footer-fr/item"
  let mapping _ = [
    "url",  Mk.esc (#url) ;
    "name", Mk.esc (#name) ;
  ]
end)  

module Footer = Loader.Html(struct
  type t = FooterItem.t list
  let source    = function `Fr -> "footer-fr"
  let mapping l = [ "item", Mk.list identity (FooterItem.template l) ]
end)

module OfferInclude = Loader.Html(struct
  type t = string
  let source  _ = "offer/include"
  let mapping _ = [ "text", Mk.esc identity ] 
end)

module Offer = Loader.Html(struct
  type t = <
    title : string ;
    text  : string ;
    inc   : OfferInclude.t list ;
    price : string 
  > ;;
  let source  _ = "offer"
  let mapping l = [
    "title",   Mk.esc  (#title) ;
    "text",    Mk.str  (#text |- VText.format) ;
    "include", Mk.list (#inc) (OfferInclude.template l) ;
    "price",   Mk.esc  (#price)
  ] 
end)

module PricingColumnItem = Loader.Html(struct
  type t = <
    link : string ;
    name : string 
  > ;;
  let source  _ = "pricing/column/item"
  let mapping _ = [
    "link", Mk.esc (#link) ;
    "name", Mk.esc (#name) 
  ] 
end)

module PricingColumn = Loader.Html(struct
  type t = PricingColumnItem.t list
  let source  _ = "pricing/column"
  let mapping _ = [
    "item", Mk.ihtml (fun x i c -> 
      View.implode (View.str "<br/>") 
	(fun item -> PricingColumnItem.render item i) x c)
  ]
end)

type pricing_line_cell = <
  ticked : bool ;
  text   : string option ;
  link   : string option
> ;;

type pricing_line = <
  cells : pricing_line_cell list ;
  label : string
>

module PricingLineCell = Loader.Html(struct
  type t = int * pricing_line_cell
  let source  _ = "pricing/line/cell"
  let mapping _ = [
    "css", Mk.esc (fun (n,x) ->
      (if n = 0 then "-asso " else "")
      ^ (if (x # ticked) then "-tick" else "")) ;
    "content", Mk.html (fun (_,x) ->
      match x # text, x # link with 
	| None, _ -> View.str "&nbsp;"
	| Some text, None -> View.esc text
	| Some text, Some link -> 
	  View.str "<a href=\""
	  |- View.esc link
	  |- View.str "\">"
	  |- View.esc text
	  |- View.str "</a>")
  ]
end)

module PricingLine = Loader.Html(struct
  type t = int * pricing_line
  let source  _ = "pricing/line"
  let mapping l = [
    "label", Mk.esc (snd |- (#label)) ;
    "css",   Mk.esc  (fun (n,_) -> 
      if n = 0 then "-price" else if n mod 2 = 1 then "-alt" else "") ;
    "cell",  Mk.list (fun (_,x) -> BatList.mapi (fun i x -> i,x) (x # cells)) 
      (PricingLineCell.template l) 
  ]
end)

module Pricing = Loader.Html(struct
  type t = <
    cols : PricingColumn.t list ;
    rows : pricing_line list ;
    foot : string ;
  > ;;
  let source  _ = "pricing"
  let mapping l = [
    "foot",   Mk.str  (#foot) ;
    "column", Mk.list (#cols) (PricingColumn.template l) ;
    "line",   Mk.list (fun x -> BatList.mapi (fun i x -> i,x) (x # rows))
      (PricingLine.template l) 
  ]
end)
