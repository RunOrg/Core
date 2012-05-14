(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open BatPervasives

type item = <
  target : string ;
  title  : Ohm.I18n.text ;
  image  : string ;
  text   : Ohm.I18n.text
>

module Loader = MModel.Template.MakeLoader(struct let from = "incentive" end)

module Item = Loader.Html(struct
  type t = item
  let source  _ = "index/items"
  let mapping _ = [
    "title",  Mk.trad (#title) ;
    "target", Mk.esc  (#target) ;
    "image",  Mk.esc  (#image) ;
    "text",   Mk.trad (#text) 
  ]
end)

module Block = Loader.Html(struct
  type t = Item.t list
  let source  _ = "index"
  let mapping l = [
    "items", Mk.list identity (Item.template l)
  ]
end)

let render_block list i18n vctx = 
  if list = [] then vctx else Block.render list i18n vctx
