(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "poll" name

let _form_single = 
  let _fr = load "wall-attach" begin
    [
      "swap",          Mk.text  (#swap) ; 
      "poll-contents", Mk.ihtml (#contents) 
    ] |> FPoll.Single.Form.to_mapping
      ~prefix:"poll-form"
      ~url:    (#url) 
      ~init:   (#init)
      ~config: (#config)
      ~id:     (#id)
  end `Html in
  function `Fr -> _fr
 
let form_single ~form_url ~swap_url ~form_init ~form_config ~i18n ctx = 
  let id = Id.gen () in
  let dyn = new FPoll.Single.Form.dyn form_config i18n in 
  to_html (_form_single (I18n.language i18n)) (object
    method swap         = JsBase.to_event (Js.runFromServer swap_url)
    method contents i c = dyn # input `Question c 
    method url          = form_url
    method init         = form_init
    method config       = form_config
    method id           = id
  end) i18n ctx

let _form_multiple = 
  let _fr = load "wall-attach" begin
    [
      "swap",          Mk.text  (#swap) ; 
      "poll-contents", Mk.ihtml (#contents) ;
    ] |> FPoll.Multiple.Form.to_mapping
      ~prefix:"poll-form"
      ~url:    (#url) 
      ~init:   (#init)
      ~config: (#config)
      ~dynamic:(#dynamic)
      ~id:     (#id)
  end `Html in
  function `Fr -> _fr
 
let form_multiple ~form_url ~swap_url ~form_init ~form_config ~form_dynamic ~i18n ctx = 
  let dyn = new FPoll.Multiple.Form.dyn form_config i18n in 
  let id = Id.gen () in
  to_html (_form_multiple (I18n.language i18n)) (object
    method swap         = JsBase.to_event (Js.runFromServer swap_url)
    method contents i c = View.foreach (fun (i,_) ctx -> ctx
      |> View.str "<div class='check'>"
      |> dyn # input (`Answer i)
      |> dyn # label (`Answer i)
      |> View.str "</div>") (form_config # answers) c
    method url          = form_url
    method init         = form_init
    method config       = form_config
    method dynamic      = form_dynamic
    method id           = id
  end) i18n ctx

type detail = <
  name    : string ;
  picture : string ;
  url     : string ;
  status  : VStatus.t
> ;;

let _view_detail = 
  let _fr = load "wall-attach-view-detail" [
    "name",         Mk.esc  (#name) ;
    "status-class", Mk.esc  (#status |- VStatus.css_class) ;
    "status-name",  Mk.trad (#status |- VStatus.label) ;
    "image-url",    Mk.esc  (#picture)
  ] `Html in
  function `Fr -> _fr

let _view_details = 
  let _fr = load "wall-attach-view-details" [
    "list", Mk.list (#list) (_view_detail `Fr) ;
  ] `Html in
  function `Fr -> _fr

let view_details ~list ~i18n ctx = 
  to_html (_view_details (I18n.language i18n)) (object
    method list = (list : detail list)
  end) i18n ctx

let _view_item = 
  let _fr = load "wall-attach-view-item" [
    "id",      Mk.esc  (#id |- Id.str) ;
    "details", Mk.text (#details) ;
    "answer",  Mk.trad (#answer) ;
    "count",   Mk.int  (#count) ;
    "percent", Mk.esc  (#percent) ;
  ] `Html in
  function `Fr -> _fr

let _view = 
  let _fr = load "wall-attach-view" [
    "swap",    Mk.text (#swap) ;
    "total",   Mk.int  (#total) ;
    "lines",   Mk.list (#list) (_view_item `Fr)
  ] `Html in
  function `Fr -> _fr

let view ~details ~swap ~stats ~i18n ctx = 
  let total = float_of_int (max 1 (stats # total)) in
  to_html (_view (I18n.language i18n)) (object 
    method swap    = JsBase.to_event (Js.runFromServer swap) 
    method total   = stats # total 
    method list    = BatList.mapi (fun n (answer, count) -> 
      let id = Id.gen () in
      (object
	method id      = id
	method answer  = answer
	method count   = count
	method details = JsBase.to_event (Js.lazyPick (details n) (Id.sel id))
	method percent = Printf.sprintf "%.2f" (100. *. float_of_int count /. total)
       end)) (stats # answers)
  end) i18n ctx

