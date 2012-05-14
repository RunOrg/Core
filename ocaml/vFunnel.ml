(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "funnel" end)

module VHelp = Loader.Html(struct
  type t = unit
  let source = function `Fr -> "help-fr"
  let mapping _ = []
end)

module PickVertical_Item = Loader.Html(struct
  type t = < 
    title : I18n.text ;
    summary : string ;
    url : string
  > ;;
  let source  _ = "start/pick-vertical/verticals"
  let mapping _ = [
    "title",   Mk.trad (#title) ;
    "summary", Mk.esc  (#summary) ;
    "url",     Mk.esc  (#url) ;
  ]
end)

module PickVertical = Loader.Html(struct
  type t = PickVertical_Item.t list 
  let source  _ = "start/pick-vertical"
  let mapping l = [
    "help",      Mk.sub  (fun x -> ()) (VHelp.template l) ;
    "verticals", Mk.list (fun x -> x)  (PickVertical_Item.template l)
  ]
end)

module Vertical = Loader.Html(struct
  type t = < 
    title   : I18n.text ;
    summary : string ;
    catalog : string
  > ;;
  let source  _ = "start/vertical"
  let mapping _ = [ 
    "title",   Mk.trad (#title) ;
    "summary", Mk.esc  (#summary) ;
    "catalog", Mk.esc  (#catalog) 
  ]
end)

module Form = Loader.Html(struct
  type t = bool
  let source  _ = "start/form"
  let mapping _ = [
    "submit", Mk.trad (fun x -> `label (if x then "create" else "continue"))
  ]
end)

module LoginForm = Loader.Html(struct
  type t = unit
  let source  _ = "start/account/login"
  let mapping _ = []
end)

module SignupForm = Loader.Html(struct
  type t = unit
  let source  _ = "start/account/signup"
  let mapping _ = []
end)

module Asso = Loader.Html(struct
  type t = <
    name : string ;
    desc : string ; 
    key  : string
  > ;; 
  let source  _ = "start/asso"
  let mapping _ = [
    "name", Mk.esc (#name) ;
    "desc", Mk.esc (#desc) ;
    "key",  Mk.esc (#key)
  ]
end)

module Account = Loader.JsHtml(struct
  type t = <
    fb_url     : string ;
    fb_app_id  : string ;
    fb_channel : string ;
    login      : View.html ;
    signup     : View.html 
  > ;;
  let source  _ = "start/account"
  let mapping _ = [
    "login",     Mk.html (#login) ;
    "signup",    Mk.html (#signup) ;
  ]
  let script _ = [
    "fb_url",     (fun x -> Json_type.String (x # fb_url)) ;
    "fb_channel", (fun x -> Json_type.String (x # fb_channel)) ;
    "fb_app_id",  (fun x -> Json_type.String (x # fb_app_id)) ;
  ]
end)

module Page = Loader.Html(struct
  type t = <
    pickVertical : PickVertical.t option ;
    vertical     : Vertical.t option ;
    form         : View.html option ;
    asso         : Asso.t option ;
    account      : Account.t option 
  > ;;
  let source  _ = "start"
  let mapping l = [ 
    "header",        Mk.ihtml  (fun _ -> GSplash.header) ;
    "footer",        Mk.ihtml  (fun _ -> GSplash.footer) ;
    "pick-vertical", Mk.sub_or (#pickVertical) (PickVertical.template l) Mk.empty ;
    "vertical",      Mk.sub_or (#vertical)     (Vertical.template l)     Mk.empty ;
    "form",          Mk.html   (#form |- BatOption.default identity) ;
    "asso",          Mk.sub_or (#asso)         (Asso.template l)         Mk.empty ;
    "account",       Mk.sub_or (#account)      (Account.template l)      Mk.empty
  ]
end)
