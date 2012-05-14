(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "album" name
module Loader = MModel.Template.MakeLoader(struct let from = "album" end)

module ItemComments = Loader.Html(struct
  type t = int
  let source  _ = "item/comments"
  let mapping _ = [
    "count", Mk.int identity
  ]
end)

type item = <
  url      : string ;
  by       : string ;
  by_url   : string ;
  picture  : string ;
  time     : float ;
  liked    : bool;
  likes    : int ;
  comments : int ;
  like     : string ;
  remove   : string option ;
> ;;

let _item_remove =
  let _fr = load "item-remove" [
    "remove",   Mk.text   (Js.runFromServer |- JsBase.to_event)
  ] `Html in 
  function `Fr -> _fr

let _item = 
  let _fr = load "item" [
    "by",           Mk.esc    (#by) ;
    "image-url",    Mk.esc    (#picture) ;
    "time",         Mk.ihtml  (#time |- VDate.render) ;
    "url",          Mk.esc    (#url) ;
    "by-url",       Mk.esc    (#by_url) ;
    "like",         Mk.text   (#like |- Js.like |- JsBase.to_event) ;
    "liked",        Mk.str    (fun x -> if x # liked then " -liked" else "") ;
    "likes",        Mk.int    (#likes) ;
    "remove",       Mk.sub_or (# remove) (_item_remove `Fr) Mk.empty ;
    "comments",     Mk.sub_or (fun x -> if x # comments = 0 then None else Some (x # comments))
      (ItemComments.template `Fr) Mk.empty
  ] `Html in
  function `Fr -> _fr

let _more_link = 
  let _fr = load "more-link" [
    "onclick", Mk.text identity
  ] `Html in
  function `Fr -> _fr

let _empty = VCore.empty VIcon.Large.images (`label "album.empty")

let _forbidden = VCore.empty VIcon.Large.lock (`label "album.forbidden")

let forbidden ~i18n ctx = 
  to_html _forbidden () i18n ctx

let _more = 
  let _fr = load "more" [  
    "list", Mk.list_or (#list) (_item `Fr) (Mk.empty) ;
    "more", Mk.sub_or  (#more) (_more_link `Fr) (Mk.empty) ;
  ] `Html  in
  function `Fr -> _fr

let more ~more ~list ~i18n ctx = 
  to_html (_more (I18n.language i18n)) (object
    method list = (list : item list) 
    method more = more
  end) i18n ctx

module Upload = Loader.JsHtml(struct
  type t = <
    available : float ;
    total     : float ;
    prepare   : string
  > ;;
  let source  _ = "upload"
  let mapping _ = [
    "space-available", Mk.esc (#available |- max 0.0 |- Printf.sprintf "%.0f") ;
    "space-total",     Mk.esc (#total     |- max 0.0 |- Printf.sprintf "%.0f") ;
  ]
  let script  _ = [
    "prepare_url", (#prepare |- Json_type.Build.string)
  ]
end)

let upload ~available ~total ~prepare ~i18n ctx =
  Upload.render (object
    method available = available
    method total     = total
    method prepare   = prepare
  end) i18n ctx
    
module Actions = Loader.Html(struct
  type t = JsCode.t
  let source  _ = "page/actions"
  let mapping _ = [
    "action", Mk.text JsBase.to_event
  ]
end)

module Missing = Loader.Html(struct
  type t = unit
  let source  _ = "missing"
  let mapping _ = []
end)

module ShowItemImage = Loader.Html(struct
  type t = string * (string option)
  let source  _ = "show-item/image"
  let mapping _ = [
    "url",      Mk.esc fst ;
    "next_url", Mk.esc (snd |- BatOption.default "javascript:void(0)") ;
  ]
end)

module ShowItem = Loader.Html(struct
  type t = <
    contents : View.Context.box View.t ;
    back     : string ;
    url      : string option ;
    prev     : string option ;
    next     : string option ;
  > ;; 
  let source  _ = "show-item"
  let mapping l = [
    "contents", Mk.html (#contents) ;
    "back",     Mk.esc  (#back) ;
    "next_url", Mk.esc  (#next |- BatOption.default "javascript:void(0)") ;
    "prev_url", Mk.esc  (#prev |- BatOption.default "javascript:void(0)") ;
    "next_att", Mk.str  (fun x -> if x # next = None then " disabled=\"disabled\"" else "") ; 
    "prev_att", Mk.str  (fun x -> if x # prev = None then " disabled=\"disabled\"" else "") ; 
    "image",    Mk.sub_or
      (fun x -> BatOption.map (fun url -> url, x # next) x # url)
      (ShowItemImage.template l) (Mk.empty) ;

  ]
end)

let _page = 
  let _fr = load "page" [
    "actions", Mk.sub_or  (#actions) (Actions.template `Fr) (Mk.empty) ;
    "list",    Mk.list_or (#list) (_item `Fr) _empty ;
    "more",    Mk.sub_or  (#more) (_more_link `Fr) (Mk.empty) 
  ] `Html  in
  function `Fr -> _fr
    
let page ~actions ~more ~list ~i18n ctx = 
  to_html (_page (I18n.language i18n)) (object
    method list    = (list : item list) 
    method more    = more
    method actions = actions
  end) i18n ctx
      
module Home = struct
  
  let _empty = VCore.empty VIcon.Large.images (`label "album.list.empty")

  let _pending = 
    let _fr = load "home-pending" [
      "count", Mk.esc (fun x -> string_of_int x)
    ] `Html in 
    function `Fr -> _fr

  let _item = 
    let _fr = load "home-item" [
      "url",     Mk.esc  (#url) ;
      "name",    Mk.trad (#name) ;
      "desc",    Mk.esc  (#desc) ;
      "count",   Mk.int  (#count) ;
      "pending", Mk.sub_or (fun x -> match x # pending with None -> None | Some 0 -> None | Some x -> Some x) 
	(_pending `Fr) (Mk.empty)
    ] `Html in 
    function `Fr -> _fr	

  class item ~url ~name ~desc ~count ~pending = object

    val      url = (url : string)
    method   url = url

    val     name = (name : I18n.text)
    method  name = name

    val     desc = (desc : string)
    method  desc = desc

    val    count = (count : int)
    method count = count

    val    pending = (pending : int option)
    method pending = pending 

  end


  let home = 
    let _home = 
      let _fr = load "home" [ 
	"list",    Mk.list_or (#list) (_item `Fr) (_empty);
	"actions", Mk.ihtml   (#actions)	    
      ] `Html in 
      function `Fr -> _fr
    in
    fun ~(list:item list) ~actions ~i18n ctx ->
      let template = _home (I18n.language i18n) in 
      to_html template (object
	method list    = list	  
	method actions i18n ctx = VActionList.list ~list:actions ~i18n ctx
      end) i18n ctx
	
end
