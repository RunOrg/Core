(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template

let load name = MModel.Template.load "event" name

let _create_button = 
  let _fr = load "home-create"  [
    "click", Mk.text (fun x i c -> JsBase.to_event (Js.runFromServer x) c)
  ] `Html in
  function `Fr -> _fr

type item = <
  pic   : string ;
  draft : bool ;
  name  : I18n.text ;
  desc  : string option ;
  date  : string option ;
  url   : string ;
  kind  : I18n.text ;
> ;;

let _item_all  = 
  let _fr = load "home-all-item"  [
    "pic",   Mk.esc    (#pic) ;
    "draft", Mk.trad   (fun x -> if x # draft then `label "draft" else `label "") ;
    "name",  Mk.trad   (#name) ; 
    "url",   Mk.esc    (#url) ;
    "desc",  Mk.esc    (fun x -> match x # desc with Some s -> VText.head 140 s | None -> "") ;
    "date",  Mk.esc    (fun x -> match x # date with Some s -> s | None -> "") ;
    "kind",  Mk.trad   (#kind)
  ] `Html in
  function `Fr -> _fr

let _item_mine =   
  let _fr = load "home-mine-item" [
    "draft", Mk.trad (fun x -> if x # draft then `label "draft" else `label "") ;
    "name",  Mk.trad (#name) ; 
    "url",   Mk.esc  (#url) ;
    "kind",  Mk.trad (#kind)
  ] `Html in 
  function `Fr -> _fr

let _home = 
  let _empty_all  = VCore.empty VIcon.Large.calendar (`label "events.all.none") in
  let _empty_mine = Mk.empty in
  let _fr = 
    load "home" [
      "list.all",  Mk.list_or (#all) (_item_all `Fr) (_empty_all) ;
      "list.mine", Mk.list_or (#mine) (_item_mine `Fr) (_empty_mine) ;
      "create",    Mk.sub_or  (#create) (_create_button `Fr) (Mk.empty)
    ] `Html 
  in 
  function `Fr -> _fr

let home ~instance ~create ~list ~mine ~i18n ctx = 
  to_html (_home (I18n.language i18n)) (object
    method all    = (list : item list)
    method mine   = (mine : item list) 
    method create = create 
  end) i18n ctx
