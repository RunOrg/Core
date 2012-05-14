(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "add" end)

module AccessItemImg = Loader.Html(struct
  type t = string
  let source  _ = "access/list/img"
  let mapping _ = [ "url", Mk.esc identity ]
end)

module AccessItem = Loader.Html(struct
  type t = <
    url    : string ;
    img    : string option ;
    stats  : VEntity.ItemStatsLine.t list ;
    name   : I18n.text ;
    desc   : I18n.text ;
  > ;;
  let source  _ = "access/list"
  let mapping l = [
    "url",   Mk.esc    (#url) ;
    "img",   Mk.sub_or (#img)   (AccessItemImg.template l) (Mk.empty) ;
    "stats", Mk.list   (#stats) (VEntity.ItemStatsLine.template l) ;
    "name",  Mk.trad   (#name) ;
    "desc",  Mk.trad   (#desc) ;
  ]
end)

module AccessHelp = Loader.Html(struct
  type t = unit
  let source    = function `Fr -> "access-help-fr"
  let mapping _ = []
end) 

module AccessSend = Loader.Html(struct
  type t = string
  let source    = function `Fr -> "access-send-fr"
  let mapping _ = [
    "url",     Mk.esc identity ;
    "url-esc", Mk.esc Netencoding.Url.encode
  ]
end)
 
module Access = Loader.Html(struct
  type t = <
    list : AccessItem.t list ;
    home : string ;
    asso : string ;
    send : string option ;
  > ;;
  let source  _ = "access"
  let mapping l = [
    "list",   Mk.list   (#list)       (AccessItem.template l) ;
    "help",   Mk.sub    (fun _ -> ()) (AccessHelp.template l) ;
    "url-0",  Mk.esc    (#home) ;
    "name-0", Mk.esc    (#asso) ;
    "send",   Mk.sub_or (#send)       (AccessSend.template l) (Mk.empty) ;
  ]
end)

module Page = Loader.Html(struct
  type t = <
    box         : string * string ;
    home        : string ;
    asso        : string ;
    entity_url  : string ;
    entity_name : I18n.text ;
  > ;;
  let source  _ = "page"
  let mapping l = [
    "content", Mk.html (#box |- O.Box.draw_container) ;
    "url-0",   Mk.esc  (#home) ;
    "name-0",  Mk.esc  (#asso) ;
    "url-1",   Mk.esc  (#entity_url) ;
    "name-1",  Mk.trad (#entity_name) ;
  ]
end)

module ImportHelp = Loader.Html(struct
  type t = unit
  let source    = function `Fr -> "import-help-fr"
  let mapping _ = []
end)

module Import = Loader.JsHtml(struct
  type t = <
    url : string
  >
  let source  _ = "import"
  let mapping l = [
    "help", Mk.sub (fun _ -> ()) (ImportHelp.template l)
  ]
  let script  _ = [
    "url",  (#url |- Json_type.Build.string)
  ]
end)

module Search = Loader.JsHtml(struct
  type t = <
    search_url : string ;
    add_url    : string
  >
  let source  _ = "search"
  let mapping _ = []
  let script  _ = [
    "search_url", (#search_url |- Json_type.Build.string) ;
    "add_url",    (#add_url |- Json_type.Build.string)
  ]
end)

module FromBlock = Loader.JsHtml(struct
  type t = <
    id   : string ;
    kind : MEntityKind.t ;
    url  : string
  > ;;
  let source  _ = "from-block"
  let mapping _ = [
    "id",    Mk.esc  (#id) ;
    "icon",  Mk.esc  (#kind |- VIcon.of_entity_kind) ;
    "title", Mk.trad (#kind |- VLabel.of_entity_kind `plural) ;
  ]
  let script  _ = Json_type.Build.([
    "id",   (#id |- string) ;
    "url",  (#url |- string) ;
    "kind", (#kind |- MEntityKind.to_json)
  ])
end)

module FromBlockLineItem = Loader.Html(struct
  type t = < 
    id      : IEntity.t ;
    picture : string ;
    name    : I18n.text
  > ;;
  let source  _ = "from-block-line/items"
  let mapping _ = [ 
    "id",      Mk.esc  (#id |- IEntity.to_string) ;
    "picture", Mk.esc  (#picture) ;
    "name",    Mk.trad (#name)
  ]
end)

module FromBlockLine = Loader.Html(struct
  type t = FromBlockLineItem.t list
  let source  _ = "from-block-line"
  let mapping l = [
    "items", Mk.list identity (FromBlockLineItem.template l) ;
  ]
end)

module From = Loader.JsHtml(struct
  type t = <
    kind : MEntityKind.t -> FromBlock.t option ;
    url : string 
  > ;;
  let source  _ = "from"
  let mapping l = [
    "col1", Mk.list 
      (fun x -> BatList.filter_map (x # kind) [ `Group ; `Subscription ])
      (FromBlock.template l) ;
    "col2", Mk.list 
      (fun x -> BatList.filter_map (x # kind) [ `Event ; `Album ])
      (FromBlock.template l) ;
    "col3", Mk.list 
      (fun x -> BatList.filter_map (x # kind) [ `Course ; `Poll ; `Forum ])
      (FromBlock.template l) ;
  ]
  let script  _ = [
    "url", (#url |- Json_type.Build.string) 
  ]
end)
    
