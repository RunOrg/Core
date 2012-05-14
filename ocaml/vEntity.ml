(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "entity" name
module Loader = MModel.Template.MakeLoader(struct let from = "entity" end)

type hd = <
  home : string ;
  name : I18n.text ;
  desc : I18n.text ;
  join : I18n.html
> ;;

let hdmap l = [
  "name",   Mk.trad  (#name) ;
  "home",   Mk.esc   (#home) ;
  "desc",   Mk.trad  (#desc) ;
  "button", Mk.ihtml (#join) ;
]

module SidebarMaxHd = Loader.Html(struct
  type t = hd
  let source  _ = "sidebar/maxhd"
  let mapping l = hdmap l
end)

module SidebarMinHd = Loader.Html(struct
  type t = hd
  let source  _ = "sidebar/minhd"
  let mapping l = hdmap l
end)

module SidebarImage = Loader.Html(struct
  type t = string * string
  let source  _ = "sidebar/image"
  let mapping _ = [
    "pic",        Mk.esc snd ;
    "home",       Mk.esc fst 
  ]
end)

module Sidebar = Loader.JsHtml(struct
  type t = <
    box        : string * string ;
    picture    : string option ;
    name       : I18n.text ;
    sidebar    : VSidebar.Index.t ;
    home       : string ;
    url_asso   : string ;
    name_asso  : string ;
    url_list   : string ;
    kind       : MEntityKind.t ;
    desc       : I18n.text ;
    join       : I18n.html ;
    invited    : bool ;
    eid        : IEntity.t
  > ;;
  let source  _ = "sidebar"
  let mapping l = [
    "maxhd",      Mk.sub_or
      (fun x -> if x # picture = None then Some (x :> hd) else None)
      (SidebarMaxHd.template l) Mk.empty ;
    "minhd",      Mk.sub_or
      (fun x -> if x # picture <> None then Some (x :> hd) else None)
      (SidebarMinHd.template l) Mk.empty ;
    "image",      Mk.sub_or 
      (fun x -> match x # picture with None -> None | Some p -> Some (x # home, p)) 
      (SidebarImage.template l) Mk.empty ;
    "sidebar",    Mk.sub    (#sidebar) (VSidebar.Index.template l) ;
    "content",    Mk.html   (#box |- O.Box.draw_container) ;
    "url-home",   Mk.esc    (#home) ;
    "url-0",      Mk.esc    (#url_asso) ;
    "url-1",      Mk.esc    (#url_list) ;
    "name-0",     Mk.esc    (#name_asso) ;    
    "name-1",     Mk.trad   (#kind |- VLabel.of_entity_kind `plural) ;
  ]
  let script _ = Json_type.Build.([
    "invited", (#invited |- bool) ;
    "eid",     (#eid |- IEntity.to_json) ;
  ])
end)

module ItemStatsLine = Loader.Html(struct
  type t = <
    value : int ;
    css : [ `Users | `Pending ]
  > ;;
  let source _  = "item-stats-line"
  let mapping _ = [
    "value", Mk.int (#value) ;
    "css",   Mk.str (fun x -> match x # css with 
      | `Users -> "-users"
      | `Pending -> "-pending")
  ]
end)

module ItemImg = Loader.Html(struct
  type t = string
  let source  _ = "item/img"
  let mapping _ = [ "url", Mk.esc identity ]
end)

module Item = Loader.Html(struct
  type t = <
    url    : string ;
    img    : string option ;
    stats  : ItemStatsLine.t list ;
    name   : I18n.text ;
    desc   : I18n.text ;
    draft  : bool ;
    join   : I18n.html ;
    access : VAccessFlag.access option
  > ;;
  let source  _ = "item"
  let mapping l = [
    "url",   Mk.esc    (#url) ;
    "img",   Mk.sub_or (#img) (ItemImg.template l) (Mk.empty) ;
    "stats", Mk.list   (#stats) (ItemStatsLine.template l) ;
    "name",  Mk.trad   (#name) ;
    "desc",  Mk.trad   (#desc) ;
    "join",  Mk.ihtml  (#join) ;
    "flag",  Mk.ihtml  (#access |- VAccessFlag.render_right) ;
    "draft", Mk.trad   (fun x -> if x # draft then `label "draft" else `label "") ;
  ]
end)

let _public_link = 
  let _fr = load "public-link" [
    "url", Mk.esc identity
  ] `Html in
  function `Fr -> _fr

let public_link ~url ~i18n ctx =
  to_html (_public_link (I18n.language i18n)) url i18n ctx
  
module NoItems = Loader.Html(struct
  type t = <
    image : string ;
    message : I18n.text    
  > ;;
  let source  _ = "home/empty"
  let mapping _ = [
    "image",   Mk.esc  (#image) ;
    "message", Mk.trad (#message)
  ]
end)

module FutureList = Loader.Html(struct
  type t = Item.t list
  let source  _ = "home/list-future"
  let mapping l = [ 
    "list", Mk.list identity (Item.template l) ;
  ]
end) 

module TimedList = Loader.Html(struct
  type t = <
    date : float ;
    list : Item.t list 
  > ;;
  let source  _ = "home/list-timed"
  let mapping l = [ 
    "date", Mk.itext (#date |- VDate.wmdy_render) ;
    "list", Mk.list  (#list) (Item.template l) ;
  ]
end) 

module PastList = Loader.Html(struct
  type t = <
    label : I18n.text ;
    list : Item.t list 
  > ;;
  let source  _ = "home/list-past"
  let mapping l = [ 
    "title", Mk.trad (#label) ; 
    "list",  Mk.list (#list) (Item.template l) ;
  ]
end) 

module Home = Loader.Html(struct
  type t = <
    access      : VAccessFlag.access option ;
    title       : I18n.text ;
    empty       : NoItems.t option ;
    list        : Item.t list ;
    past_list   : PastList.t option ;
    timed_list  : TimedList.t list ;
    action      : I18n.html ;
    public_link : string option ; 
  > ;;
  let source  _ = "home"
  let mapping l = [
    "access",      Mk.ihtml  (#access |- VAccessFlag.render) ;
    "title",       Mk.trad   (#title) ;
    "button",      Mk.ihtml  (#action) ;
    "public-link", Mk.sub_or (#public_link) (_public_link l) (Mk.empty) ; 
    "empty",       Mk.sub_or (#empty) (NoItems.template l) (Mk.empty) ;
    "list-timed",  Mk.list   (#timed_list) (TimedList.template l) ;
    "list-past",   Mk.sub_or (#past_list) (PastList.template l) (Mk.empty) ;

    "list-future", Mk.sub_or (fun x -> 
      if x # past_list = None && x # timed_list = [] || x # list = []
      then None else Some (x # list)) (FutureList.template l) (Mk.empty) ;

    "list",        Mk.list   (fun x ->
      if x # past_list = None && x # timed_list = [] 
      then x # list else []) (Item.template l) ;
  ]
end)

let _deleted = 
  let _fr = load "deleted-fr" [
    (* Breadcrumbs *)
    "url-home", Mk.esc  (#url_home) ;
    "url-0",    Mk.esc  (#url_asso) ;
    "name-0",   Mk.esc  (#name_asso) ;
    "url-1",    Mk.esc  (#url_above) ;
    "name-1",   Mk.trad (#kind |- VLabel.of_entity_kind `plural);
    (* Deleted page *)
    "avatar-pic",  Mk.esc (#pic) ;
    "avatar-url",  Mk.esc (#url) ;
    "avatar-name", Mk.esc (#name) 
  ] `Html in
  function `Fr -> _fr
      
  let deleted ~url_asso ~name_asso ~url_home ~url_above ~pic ~url ~name ~kind ~i18n ctx = 
    to_html (_deleted (I18n.language i18n)) (object
      method url_asso   = url_asso
      method url_above  = url_above
      method url_home   = url_home
      method name_asso  = name_asso
      method name       = name
      method kind       = kind
      method pic        = pic
      method url        = url
    end) i18n ctx

let _chooser_item = 
  let _fr = load "templatePicker-item" [
    "name",  Mk.trad (fun x -> `label (x # name)) ;
    "desc",  Mk.trad (fun x -> `label (x # desc)) ; 
    "value", Mk.esc  (#value) ;
  ] `Html in
  function `Fr -> _fr

let _chooser_list = 
  let _empty = VCore.empty VIcon.Large.bricks (`label "entity.template.list.none") in
  let _fr = load "templatePicker-list" [
    "choose", Mk.text    (#choose) ;
    "cancel", Mk.text    (#cancel) ;
    "list",   Mk.list_or (#list) (_chooser_item `Fr) (_empty) ;
    "id",     Mk.esc     (#id |- Id.str) ;
  ] `Html in
  function `Fr -> _fr

let chooser_list ~templates ~isin ~i18n ~create ctx = 
  let toid = Id.gen () in
  let js   = Js.picker toid in
  let list = List.map (fun (id,data) -> (object
    method name  = data # name
    method desc  = data # desc
    method value = 
      Json_io.string_of_json ~recursive:true
	(Json_type.Build.list Json_type.Build.string
	   [ ITemplate.to_string id ;
	     ITemplate.Deduce.make_create_token id isin ])
  end)) templates in
  to_html (_chooser_list (I18n.language i18n)) (object
    method cancel = JsBase.to_event Js.Dialog.close
    method choose = JsBase.to_event (Js.sendPicked toid create)
    method list   = list
    method id     = toid 
  end) i18n (View.Context.add_js_code js ctx)

let _unavailable = 
  let _fr = load "unavailable-fr" [] `Html in
  function `Fr -> _fr

let unavailable ~i18n ctx = 
  to_html (_unavailable (I18n.language i18n)) () i18n ctx

let _wall = 
  let _fr = load "wall" [
    "content", Mk.html (#content |- O.Box.draw_container) ;
  ] `Html in
  function `Fr -> _fr

let wall ~content ~i18n ctx = 
  to_html (_wall (I18n.language i18n)) (object
    method content = content
  end) i18n ctx

module List = struct

  module Search = Loader.Html(struct
    type t = unit
    let source  _ = "grid/search"
    let mapping _ = []
  end)

  let _page = 
    let _fr = load "grid" [
      "add",         Mk.esc   (#add) ;
      "action-list", Mk.html  (#action_list) ;
      "search",      Mk.html  (#search) ;
      "url-csv",     Mk.esc   (#csv) ;
      "grid",        Mk.ihtml (#grid) ;
    ] `Html in
    function `Fr -> _fr
      
  let page ~action_list ~add ~search ~url_csv ~grid ~i18n ctx =
    let template = _page (I18n.language i18n) in
    to_html template (object
      method csv         = url_csv
      method grid        = grid
      method action_list = action_list
      method add         = add
      method search      = search
    end) i18n ctx

end

module Edit = struct

  let _page = 
    let _fr = load "edit" begin
      [
	"content",  Mk.ihtml (#content) ;
	"cancel",   Mk.esc   (#cancel) ;
      ] |> FEntity.Form.to_mapping
	~prefix: "entity-edit"
	~url:    (#url)
	~init:   (#init)
	~config: (#config)
	~dynamic:(#dynamic) 
    end `Html in
    function `Fr -> _fr
      
  let page 
      ~form_init 
      ~form_url 
      ~url_cancel 
      ~content 
      ~config 
      ~dynamic 
      ~i18n ctx = 
    to_html (_page (I18n.language i18n)) (object
      method init       = form_init
      method url        = form_url
      method config     = config
      method content    = content
      method dynamic    = dynamic
      method cancel     = url_cancel 
    end) i18n ctx

end

module View = struct

  let info ~public ~actions ~formatter ~data ~description ~layout ~i18n ctx = 
    let prelude = 
      match public with 
	| Some url -> (fun i18n ctx -> public_link ~url ~i18n ctx) 
	| None -> fun i c -> c
    in
    VVertical.Layout.render 
      ~prelude
      ~actions
      ~formatter 
      ~data 
      ~description 
      ~layout 
      ~i18n 
      ctx

end
