(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "core" name
module Loader = MModel.Template.MakeLoader(struct let from = "core" end)

let _s = View.str

(* Action boxes ------------------------------------------------------------------------ *)

module ActionBoxLink = Loader.Html(struct
  type t = <
    url   : string ;
    img   : string ;
    label : I18n.text
  >
  let source  _ = "action-box/link"
  let mapping _ = [
    "url",   Mk.esc  (#url) ;
    "img",   Mk.esc  (#img) ;
    "label", Mk.trad (#label)
  ]
end)

module ActionBoxButton = Loader.Html(struct
  type t = <
    img   : string ;
    js    : JsCode.t ;
    label : I18n.text
  >
  let source  _ = "action-box/button"
  let mapping _ = [
    "click", Mk.text (#js |- JsBase.to_event) ;
    "img",   Mk.esc  (#img) ;
    "label", Mk.trad (#label)
  ]
end)

module ActionBoxLabel = Loader.Html(struct
  type t = I18n.text
  let source  _ =  "action-box/label"
  let mapping _ = [ "title", Mk.trad identity ]
end)

module ActionBox = Loader.Html(struct
  type t = <
    title   : I18n.text option ;
    actions : [ `Link of ActionBoxLink.t | `Button of ActionBoxButton.t ] list
  > ;;
  let source  _ = "action-box"
  let mapping l = [
    "label",   Mk.sub_or (#title) (ActionBoxLabel.template l) Mk.empty ;
    "link",    Mk.put  "" ;
    "button",  Mk.put  "" ;
    "content", Mk.ihtml (fun x i -> View.foreach (function 
      | `Link l -> ActionBoxLink.render l i 
      | `Button b -> ActionBoxButton.render b i) (x # actions))
  ]
end) 

(* Various buttons and pages ----------------------------------------------------------- *)

module FollowLinkButton = Loader.Html(struct
  type t = string
  let source  _ = "button-link-follow"
  let mapping _ = [
    "url",   Mk.esc identity ;
  ]
end)

module MiniFollowLinkButton = Loader.Html(struct
  type t = string
  let source  _ = "mini-link-follow"
  let mapping _ = [
    "url",   Mk.esc identity ;
  ]
end)

module GreenLinkButton = Loader.Html(struct
  type t = string * I18n.text
  let source  _ = "button-link-green"
  let mapping _ = [
    "url",   Mk.esc  fst ;
    "label", Mk.trad snd ;
  ]
end)

module LinkButton = Loader.Html(struct
  type t = string * I18n.text
  let source  _ = "button-link"
  let mapping _ = [
    "url",   Mk.esc  fst ;
    "label", Mk.trad snd ;
  ]
end)

module GreenButton = Loader.Html(struct
  type t = JsCode.t * I18n.text
  let source  _ = "button-green"
  let mapping _ = [
    "action", Mk.text (fst |- JsBase.to_event) ;
    "label",  Mk.trad snd ;
  ]
end)

module CustomButton = Loader.Html(struct
  type t = <
    css   : string list ;
    js    : JsCode.t ;
    label : I18n.text
  > ;;
  let source  _ = "button-custom"
  let mapping _ = [
    "css",   Mk.esc  (#css |- String.concat " ") ;
    "js",    Mk.text (#js  |- JsBase.to_event) ;
    "label", Mk.trad (#label)
  ]
end)

let icon_link_button icon label = 
  load "icon-link-button" [
    "icon", Mk.esc (fun _ -> icon) ;
    "text", Mk.i18n label ;
    "link", Mk.esc (fun link -> link)
  ] `Html

let button_right : ( < click : JsCode.t ; text : I18n.text > , View.Context.box ) Template.t = 
  load "button-right" ( [
    "click", Mk.text (#click |- JsBase.to_event) ;
    "text",  Mk.trad (#text) 
  ] ) `Html 

let button_left : ( < click : JsCode.t ; text : I18n.text > , View.Context.box ) Template.t = 
  load "button-left" ( [
    "click", Mk.text (#click |- JsBase.to_event) ;
    "text",  Mk.trad (#text) 
  ] ) `Html 

let _admin_only = 
  let _fr = load "admin-only-fr" [] `Html in
  function `Fr -> _fr

let admin_only ~i18n ctx = 
  to_html (_admin_only (I18n.language i18n)) () i18n ctx
	     
let empty icon text = 
  load "empty" [
    "image",   Mk.esc  (fun _ -> icon) ;
    "message", Mk.i18n text
  ] `Html 

(* Navbar --------------------------------------------------------------------------------- *)

type assolink = < url : string ; pic : string ; name : string >

let _assolink = 
  let _fr = load "navbar/assos" [ 
    "url",  Mk.esc (#url) ;
    "pic",  Mk.esc (#pic) ;
    "name", Mk.esc (#name) ;
    "hide", Mk.str (fun x -> if x # pic = "" then " style='display:none'" else "") 
  ] `Html in
  function `Fr -> _fr

let _navbar = 
  let _fr = load "navbar" [ 
    "url-home",     Mk.esc (#url_home) ;
    "url-account",  Mk.esc (#url_account) ;
    "url-news",     Mk.esc (#url_news) ;
    "url-groups",   Mk.esc (#url_groups) ;
    "url-create",   Mk.esc (#url_create) ;
    "url-messages", Mk.esc (#url_messages) ;
    "url-logout",   Mk.esc (#url_logout) ;
    "user-name",    Mk.esc (#user_name) ;
    "name",         Mk.str (#name) ;
    "assos",        Mk.ihtml
      (fun x i c ->	
	let template = _assolink (I18n.language i) in
	View.implode 
	  identity 
	  (fun elem -> to_html template elem i)
	  (x # instances) c)
  ] `Html in
  function `Fr -> _fr

let navbar 
    ~url_home
    ~url_account
    ~url_news
    ~url_groups
    ~url_messages
    ~url_logout
    ~url_create
    ~user_name
    ~news_count 
    ~name
    ~message_count
    ~(instances : assolink list)
    ~i18n (ctx:View.Context.box) = 
  Template.to_html 
    (_navbar (I18n.language i18n)) 
    (object
      method url_home     = url_home
      method url_account  = url_account
      method url_news     = url_news
      method url_groups   = url_groups
      method url_messages = url_messages
      method url_logout   = url_logout
      method url_create   = url_create
      method user_name    = user_name
      method instances    = instances
      method name         = name
     end) i18n ctx
  |> View.Context.add_js_code (JsCode.seq [
    Js.notify ~id:`news ~unread:(news_count # unread) ~total:(news_count # total) ;
    Js.notify ~id:`message ~unread:(message_count) ~total:(message_count) ;
  ]) 

let _navbar_empty =  
  let _fr = load "navbar-empty" [
    "title", Mk.trad (#title) ;
    "name",  Mk.str  (#name)
  ] `Html in
  function `Fr -> _fr

let navbar_empty name ~title ~i18n (ctx:View.Context.box) = 
  to_html (_navbar_empty (I18n.language i18n)) (object
    method title = title
    method name  = name
  end) i18n ctx

(* Rendering a 404 page --------------------------------------------------------------------- *)

let head_mapping () = 
  [ "title",     Mk.trad (#title) ;
    "index.url", Mk.put "/" ]

