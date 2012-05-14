(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "message" name

let _not_yet = 
  let _fr = load "empty-fr" [] `Html in
  function `Fr -> _fr

let not_yet ~i18n ctx = 
  to_html (_not_yet (I18n.language i18n)) () i18n ctx

type item_content = <
  picture  : string ;
  time     : float ;
  url      : string ;
  title    : string ;
  read     : bool ;
  people   : string 
> ;;

let _item = 
  let _fr = load "item" [
    "picture",    Mk.esc   (#picture) ;
    "time",       Mk.ihtml (#time |- VDate.render) ;
    "url",        Mk.esc   (#url) ;
    "title",      Mk.esc   (#title) ;
    "isnew",      Mk.str   (fun x -> if x # read then "" else " is-new") ;
    "people",     Mk.esc   (#people)
  ] `Html in
  function `Fr -> _fr   

type asso_item = <
  name     : string ;
  status   : VStatus.t ;
  url      : string ;
  pic      : string ;
  unread   : int 
>

let _asso = 
  let _fr = load "asso" [
    "name",         Mk.esc  (#name) ;
    "status-name",  Mk.trad (#status |- VStatus.label) ;
    "status-class", Mk.esc  (#status |- VStatus.css_class) ;
    "url",          Mk.esc  (#url) ;
    "picture",      Mk.esc  (#pic) ;
    "with-unread",  Mk.str  (fun x -> if x # unread > 0 then "unread" else "") ;
    "unread",       Mk.int  (#unread) ;
  ] `Html in
  function `Fr -> _fr

let _buttons = 
  let _fr = load "buttons" [
    "new", Mk.text JsBase.to_event
  ] `Html in
  function `Fr -> _fr

let _home = 
  let _empty_messages = VCore.empty VIcon.Large.email (`label "messages.empty") in
  let _fr = load "index" [
    "asso-img", Mk.esc     (#asso_img) ;
    "asso-url", Mk.esc     (#asso_url) ;
    "asso",     Mk.esc     (#asso) ;
    "assos",    Mk.list    (#assos) (_asso `Fr) ;
    "buttons",  Mk.sub_or  (#buttons) (_buttons `Fr) (Mk.empty);
    "messages", Mk.list_or (#messages) (_item `Fr) (_empty_messages);
  ] `Html in
  function `Fr -> _fr

let home ~asso_img ~asso_url ~messages ~create ~assos ~instance ~i18n ctx =   
  to_html (_home (I18n.language i18n)) (object
    method asso     = instance # name
    method asso_url = asso_url 
    method asso_img = asso_img
    method assos    = (assos : asso_item list)
    method messages = (messages : item_content list)
    method buttons  = BatOption.map Js.runFromServer create
  end) i18n ctx

let _create = 
  let _fr = load "create" begin
    []
    |> FMessage.Create.Form.to_mapping 
      ~prefix:"create-message"
      ~url:   (#form_url)
      ~init:  (#form_init)
  end `Html in
  function `Fr -> _fr

let create ~url ~init ~i18n ctx = 
  to_html (_create (I18n.language i18n)) (object
    method form_url = url
    method form_init = init
  end) i18n ctx

type participant = <
  picture : string ;
  status  : VStatus.t ;
  name    : string ;
  id      : IAvatar.t ;
  url     : string
> 

let _participant = 
  let _fr = load "participant" [
    "picture",      Mk.esc  (#picture) ;
    "name",         Mk.esc  (#name) ;
    "status-name",  Mk.trad (#status |- VStatus.label) ;
    "status-class", Mk.esc  (#status |- VStatus.css_class) ;
    "id",           Mk.esc  (#id |- IAvatar.to_string)  ;
    "url",          Mk.esc  (#url) ;      
  ] `Html in
  function `Fr -> _fr

let participant ~picture ~status ~name ~id ~url ~i18n ctx = 
  to_html (_participant (I18n.language i18n)) (object
    method picture = picture
    method name    = name
    method status  = status
    method id      = id
    method url     = url
  end) i18n ctx

let _group = 
  let _fr = load "group" [
    "id",  Mk.esc (#id |- Id.str) ;
    "icon", Mk.esc (fun x -> match x # name with 
      | None -> VIcon.lock 
      | Some _ -> VIcon.of_entity_kind (x # kind)) ;
    "name", Mk.trad (fun x -> match x # name with 
      | None -> `label "messages.group.hidden" 
      | Some None -> `label "entity.untitled"
      | Some (Some t) -> t) ;
    "kind", Mk.trad (fun x -> match x # name with 
      | None -> `label ""
      | Some _ -> VLabel.of_entity_kind `single (x # kind)) ;
    "status", Mk.trad (fun x -> match x # access with 
      | `Any       -> `label "entity.status.any"
      | `Validated -> `label "entity.status.validated"
      | `Pending   -> `label "entity.status.pending")
  ] `Html in
  function `Fr -> _fr

let group ~id ~kind ~name ~access ~i18n ctx = 
  to_html (_group (I18n.language i18n)) (object
    method id     = id
    method name   = name
    method kind   = kind
    method access = (access : MAccess.State.t)
  end) i18n ctx

type add_info = <
  url : string ;
  init : FMember.Select.Form.t ;
  config : FMember.Select.Fields.config
>

let _add_form = 
  let _fr = load "participant-add" begin
    [] |> FMember.Select.Form.to_mapping
      ~prefix: "add-form"
      ~url:    (#url) 
      ~init:   (#init)
      ~config: (#config) 
  end `Html in
  function `Fr -> _fr

let _single = 
  let _fr = load "page" [
    "title",      Mk.esc    (#title) ;
    "content",    Mk.html   (#content |- O.Box.draw_container) ;
    "people",     Mk.list   (#people) (_participant `Fr) ;
    "groups",     Mk.list   (#groups) (_group `Fr) ;
    "url-0",      Mk.esc    (#url_asso) ;
    "name-0",     Mk.esc    (#name_asso) ;
    "url-1",      Mk.esc    (#url_msg) ;
    "name-1",     Mk.i18n   (`label "messages.title") ;
    "add-form",   Mk.sub_or (#add) (_add_form `Fr) (Mk.empty) ;
    "people_id",  Mk.esc    (#people_id |- Id.str) ;
  ] `Html in 
  function `Fr -> _fr

let single ~add ~people ~entities ~people_id ~name_asso ~url_asso ~url_msg ~content ~title ~i18n ctx = 
  to_html (_single (I18n.language i18n)) (object
    method title     = title
    method content   = content
    method url_asso  = url_asso
    method name_asso = name_asso
    method url_msg   = url_msg
    method add       = (add : add_info option)
    method people    = (people : participant list)
    method groups    = List.map (fun (i,a,k,n) -> (object 
      method id     = i
      method kind   = k
      method name   = n
      method access = a
    end)) entities
    method people_id = people_id
  end) i18n ctx

let _missing = 
  let _fr = load "missing-fr" [
    "url", Mk.esc (#url)
  ] `Html in 
  function `Fr -> _fr

let missing ~url_msg ~i18n ctx = 
  to_html (_missing (I18n.language i18n)) (object
    method url = url_msg
  end) i18n ctx

let _group_denied = 
  let _fr = load "group-denied-fr" [] `Html in
  function `Fr -> _fr

let group_denied ~i18n ctx = 
  to_html (_group_denied (I18n.language i18n)) () i18n ctx

