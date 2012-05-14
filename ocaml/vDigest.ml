(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "digest" end) 

module NextItem = Loader.Html(struct
  type t = <
    url   : string ;
    time  : float ;
    title : string
  > ;;
  let source  _ = "page/item/next-box/next"
  let mapping _ = [ 
    "url",   Mk.esc   (#url) ;
    "time",  Mk.itext (#time |- VDate.render) ; 
    "title", Mk.esc   (#title)
  ] 
end)

module NextItemBox = Loader.Html(struct
  type t = NextItem.t list
  let source  _ = "page/item/next-box"
  let mapping l = [ 
    "next", Mk.list identity (NextItem.template l) 
  ] 
end)

module Via = Loader.Html(struct
  type t = string * string
  let source  _ = "page/item/via"
  let mapping _ = [
    "url",  Mk.esc fst ;
    "name", Mk.esc snd
  ] 
end)

module ItemRSS = Loader.Html(struct
  type t = string
  let source  _ = "page/item/rss"
  let mapping _ = [
    "url", Mk.str VText.secure_link 
  ]
end)

module Item = Loader.Html(struct
  type t = <
    from_pic : string ;
    from     : string ;
    from_url : string ;
    via      : Via.t option ;
    url      : string ;
    time     : float ;
    text     : string ;
    title    : string ;
    next     : NextItem.t list ;
    rss      : ItemRSS.t option ;
  > ;;
  let source  _ = "page/item"
  let mapping l = [
    "from-pic", Mk.esc    (#from_pic) ;
    "from"    , Mk.esc    (#from) ;
    "from-url", Mk.esc    (#from_url) ;
    "url"     , Mk.esc    (#url) ;
    "via"     , Mk.sub_or (#via) (Via.template l) Mk.empty ;
    "time"    , Mk.itext  (#time |- VDate.render) ;
    "text"    , Mk.str    (#text) ;
    "title"   , Mk.esc    (#title) ;
    "rss"     , Mk.sub_or (#rss) (ItemRSS.template l) Mk.empty ;
    "next-box", Mk.sub_or (fun x -> if x#next = [] then None else Some (x#next))
      (NextItemBox.template l) Mk.empty 
  ]
end)

let empty = VCore.empty VIcon.Large.newspaper (`label "me.digest.empty") 

module Page = Loader.JsHtml(struct
  type t = <
    list : Item.t list ;
    more : string ;
  > ;; 
  let source  _ = "page"
  let mapping l = [
    "item", Mk.list_or (#list) (Item.template l) empty 
  ]
  let script  _ = Json_type.Build.([
    "label", (#more |- string) 
  ])
end)

module UnsubscribeFail = Loader.Html(struct
  type t = I18n.text
  let source    = function `Fr -> "unsubscribe-fail-fr"
  let mapping _ =
    [ "title",     Mk.trad identity ]
end)

module UnsubscribeOk = Loader.Html(struct
  type t = I18n.text
  let source    = function `Fr -> "unsubscribe-ok-fr"
  let mapping _ =
    [ "title",     Mk.trad identity ]
end)

module Unsubscribe = Loader.Html(struct
  type t = I18n.text * string
  let source    = function `Fr -> "unsubscribe-fr"
  let mapping _ =
    [ "title",     Mk.trad fst ;
      "url",       Mk.esc  snd ]
end)
