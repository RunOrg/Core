(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "feed" name

(* Wrapping info around in an item *)

let _item = 
  let _fr = load "item" [
    "url",  Mk.esc   (#url) ;
    "pic",  Mk.esc   (#pic) ;
    "body", Mk.ihtml (#body) ;
    "icon", Mk.esc   (#icon) ;
    "date", Mk.ihtml (#date |- VDate.render)
  ] `Html in
  function `Fr -> _fr

let item_wrap ~url ~pic ~icon ~date i18n ctx body = 
  to_html (_item (I18n.language i18n)) (object
    method url = url
    method pic = pic
    method body = body
    method icon = icon
    method date = date
  end) i18n ctx

let _item_line = 
  let _fr = load "item-line" [
    "body", Mk.ihtml (#body) ;
    "icon", Mk.esc   (#icon) ;
    "date", Mk.ihtml (#date |- VDate.render) 
  ] `Html in
  function `Fr -> _fr

let item_line_wrap ~icon ~date i18n ctx body = 
  to_html (_item_line (I18n.language i18n)) (object
    method body = body
    method icon = icon
    method date = date
  end) i18n ctx

(* Putting together a list of items with a more link *)

let _more_item = 
  let _any = load "more-item" [
    "item", Mk.html identity
  ] `Html in
  function `Fr -> _any

let _more_link = 
  let _any = load "more-link" [
    "url", Mk.text JsBase.to_event
  ] `Html in 
  function `Fr -> _any

let _more = 
  let _any = load "more" [
    "feed", Mk.list   (#feed) (_more_item `Fr) ;    
    "next", Mk.sub_or (#next) (_more_link `Fr) (Mk.empty) ;
  ] `Html in
  function `Fr -> _any

let more ~feed ~next ~i18n ctx = 
  to_html (_more (I18n.language i18n)) (object
    method feed = feed
    method next = next
  end) i18n ctx

module Wall = struct

  let _item_entity = 
    let _fr = load "wall_item_entity-fr" [
      "name",        Mk.esc  (#name) ;
      "url",         Mk.esc  (#url) ;
      "entity-url",  Mk.esc  (#entity_url) ;
      "entity-name", Mk.trad (#entity_name) ;
      "text",        Mk.str  (#text |- VText.format)
    ] `Html in
    function `Fr -> _fr

  let item_entity ~url ~pic ~icon ~name ~entity_url ~entity_name ~text ~date ~i18n ctx = 
    to_html (_item_entity (I18n.language i18n)) (object
      method name        = name
      method url         = url
      method entity_url  = entity_url
      method entity_name = entity_name
      method text        = text
    end)
    |> item_wrap ~url ~pic ~icon ~date i18n ctx

  let _item_message = 
    let _fr = load "wall_item_message-fr" [
      "name",         Mk.esc (#name) ;
      "url",          Mk.esc (#url) ;
      "message-url",  Mk.esc (#message_url) ;
      "message-name", Mk.esc (#message_name) ;
      "text",         Mk.str (#text |- VText.format) ;
    ] `Html in
    function `Fr -> _fr

  let item_message ~url ~pic ~icon ~name ~message_url ~message_name ~text ~date ~i18n ctx = 
    to_html (_item_message (I18n.language i18n)) (object
      method name         = name
      method url          = url
      method message_url  = message_url
      method message_name = message_name
      method text         = text
    end)
    |> item_wrap ~url ~pic ~icon ~date i18n ctx

  let _item = 
    let _fr = load "wall_item-fr" [
      "name",        Mk.esc  (#name) ;
      "url",         Mk.esc  (#url) ;
      "item-url",    Mk.esc  (#item_url) ;
      "text",        Mk.str  (#text |- VText.format) 
    ] `Html in
    function `Fr -> _fr

  let item ~url ~pic ~icon ~name ~item_url ~text ~date ~i18n ctx = 
    to_html (_item (I18n.language i18n)) (object
      method name        = name
      method url         = url
      method item_url    = item_url
      method text        = text
    end)
    |> item_wrap ~url ~pic ~icon ~date i18n ctx

end

module Join = struct
        
  let with_by template icon ~by_name ~by_url ~entity_name ~entity_url ~date ~name ~url ~i18n ctx = 
    to_html (template (I18n.language i18n)) (object
      method by_name     = by_name
      method by_url      = by_url
      method name        = name
      method url         = url 
      method entity_name = entity_name
      method entity_url  = entity_url 
    end)
    |> item_line_wrap ~icon ~date i18n ctx
	
  let simple  template icon ~entity_name ~entity_url ~date ~name ~url ~i18n ctx = 
    to_html (template (I18n.language i18n)) (object
      method name        = name
      method url         = url 
      method entity_name = entity_name
      method entity_url  = entity_url 
    end)
    |> item_line_wrap ~icon ~date i18n ctx
	
  let _with_by name = 
    let _fr = load (name ^ "-fr") 
      [ "by-name",     Mk.esc  (#by_name) ;
	"by-url",      Mk.esc  (#by_url) ;
	"name",        Mk.esc  (#name) ;
	"url",         Mk.esc  (#url) ;
	"entity-name", Mk.trad (#entity_name) ;
	"entity-url",  Mk.esc  (#entity_url) ]
      `Html in 
    function `Fr -> _fr
      
  let _simple name = 
    let _fr = load (name ^ "-fr")
      [ "name",        Mk.esc  (#name) ;
	"url",         Mk.esc  (#url) ;
	"entity-name", Mk.trad (#entity_name) ;
	"entity-url",  Mk.esc  (#entity_url) ]
      `Html in
    function `Fr -> _fr

  let invited      = with_by (_with_by "join-invited")      VIcon.help 
  let declined     = simple  (_simple  "join-declined")     VIcon.cross
  let self_added   = simple  (_simple  "join-self_added")   VIcon.add
  let added        = with_by (_with_by "join-added")        VIcon.add
  let requested    = simple  (_simple  "join-requested")    VIcon.exclamation 
  let self_removed = simple  (_simple  "join-self_removed") VIcon.delete
  let removed      = with_by (_with_by "join-removed")      VIcon.delete	

end

let _empty = VCore.empty VIcon.Large.newspaper (`label "feed.empty")

let empty i18n ctx = 
  to_html _empty () i18n ctx
