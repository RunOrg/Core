(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "member" name

module Loader = MModel.Template.MakeLoader(struct let from = "member" end)

module ImportForm = Loader.Html(struct
  type t = string
  let source = function `Fr -> "import-form-fr"
  let mapping _ = [] |> FMember.Import.Form.to_mapping
      ~prefix:"import-form"
      ~url:identity
      ~init:(fun _ -> FMember.Import.Form.empty)
end)

module ImportMailForm = Loader.Html(struct
  type t = string
  let source = function `Fr -> "import-mail-form-fr"
  let mapping _ = [] |> FMember.Import.Form.to_mapping
      ~prefix:"import-form"
      ~url:identity
      ~init:(fun _ -> FMember.Import.Form.empty)
end)

module Picker = struct

  let component = 
    let _component = 
      let _fr = load "picker" [
	"idto", Mk.esc (fun x -> Id.str (x # idto)) ;
	"id",   Mk.esc (fun x -> Id.str (x # id)) ;
	"name", Mk.esc (#name) ;
      ] `Html in
      function `Fr -> _fr
    in
    fun ~id ~name ~url ~i18n ctx ->
      let idto = id and id = Id.of_string (Id.str id^"-show") in
      to_html (_component (I18n.language i18n)) (object
	method id   = id
	method idto = idto
	method name = name
      end) i18n ctx
      |> View.Context.add_js_code (Js.autocomplete id idto url)
end

module Home = struct
  
  let _item = 
    let _fr = load "home-item" [
      "url",   Mk.esc  (#url) ;
      "name",  Mk.trad (#name) ;
      "desc",  Mk.trad (#desc) ;
      "count", Mk.esc  (fun x -> string_of_int (x # count));
    ] `Html in 
    function `Fr -> _fr	

  class item ~url ~name ~desc ~count = object

    val      url = (url : string)
    method   url = url

    val     name = (name : I18n.text)
    method  name = name

    val     desc = (desc : I18n.text)
    method  desc = desc

    val    count = (count : int)
    method count = count

  end

  let home = 
    let _home = 
      let _fr = load "home" [ 
	"list",    Mk.list  (#list) (_item `Fr) ;
	"actions", Mk.ihtml (#actions)	    
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

module Create = struct

  let page = 
    let _page = 
      let _fr = load "create" begin
	[ "cancel", Mk.esc (#cancel) ] 
	|> FMember.Create.Form.to_mapping
	  ~prefix: "member-create"
	  ~url:    (#url) 
	  ~init:   (#init)
	  ~config: (#config) 
      end `Html in
      function `Fr -> _fr
    in
    fun ~uploader ~gender ~form_url ~form_init ~cancel ~i18n ctx ->
      let template = _page (I18n.language i18n) in
      to_html template (object
	method url    = form_url
	method init   = form_init
	method cancel = cancel
	method config = (object
	  method uploader = uploader i18n
	  method gender   = gender   i18n
	end) 
      end) i18n ctx 

end

module Category = struct

  module Add = struct

    let _form = 
      let _fr = load "add-form" begin
	[] |> FMember.Select.Form.to_mapping
	    ~prefix: "add-form"
	    ~url:    (#url) 
	    ~init:   (#init)
	    ~config: (#config) 
      end `Html in
      function `Fr -> _fr
    
    let form ~url ~init ~config ~i18n ctx =
      let template = _form (I18n.language i18n) in
      to_html template (object
	method url    = url
	method init   = init
	method config = config
      end) i18n ctx

  end

  module List = struct
      	
    let locked = 
      let _locked = 
	let _fr = load "grid-locked-fr" [] `Html in
	function `Fr -> _fr
      in
      fun ~url ~i18n ctx ->
	let template = _locked (I18n.language i18n) in
	to_html template () i18n ctx
	|> View.Context.add_js_code (Js.wait url Js.panic)
      
    let no_columns = 
      let _no_columns = 
	let _fr = load "grid-no_columns-fr" [
	  "config", Mk.esc (#url) ; 
	] `Html in
	function `Fr -> _fr
      in 
      fun ~url ~i18n ctx ->
	to_html (_no_columns (I18n.language i18n)) (object
	  method url = url
	end) i18n ctx

  end

  let page = 
    let _page = 
      let _fr = load "page" [
	"url-home", Mk.esc   (#home) ;
	"url-0",    Mk.esc   (#url_asso) ;
	"name-0",   Mk.esc   (#asso) ;
	"url-pic",  Mk.esc   (#pic) ;
	"title",    Mk.esc   (#title) ;
	"desc",     Mk.esc   (#desc) ;
	"content",  Mk.html  (#content) ;
	"url-1",    Mk.esc   (#above) ;
	"name-1",   Mk.i18n  (`label "menu.groups") ;
	"button",   Mk.put   ("")
      ] `Html in 
      function `Fr -> _fr
    in
    fun ~url_asso ~asso ~url_above ~url_home ~url_pic ~title ~desc ~content ~i18n ctx ->
      let template = _page (I18n.language i18n) in
      to_html template (object
	method asso     = asso
	method url_asso = url_asso
	method home     = url_home
	method pic      = url_pic
	method title    = title
	method desc     = desc
	method above    = url_above
	method content  = O.Box.draw_container content
      end) i18n ctx

end

module Autocomplete = struct

  let _item = 
    let _fr = load "autocomplete-item" [
      "name", Mk.esc          (#name) ;
      "status-class", Mk.esc  (#status |- VStatus.css_class) ;
      "status-name",  Mk.trad (#status |- VStatus.label) ;
      "image-url",    Mk.esc  (#pic)
    ] `Html in
    function `Fr -> _fr

  let item ~name ~status ~pic ~i18n ctx = 
    to_html (_item (I18n.language i18n)) (object
      method name   = name
      method status = status
      method pic    = pic
    end) i18n ctx

end

module AutocompleteJoy = struct

  let _item = 
    let _fr = load "autocomplete-item-joy" [
      "name",         Mk.esc  (#name) ;
      "status-class", Mk.esc  (#status |- VStatus.css_class) ;
      "status-name",  Mk.trad (#status |- VStatus.label) ;
      "image-url",    Mk.esc  (#pic)
    ] `Html in
    function `Fr -> _fr

  let item ~name ~status ~pic ~i18n ctx = 
    to_html (_item (I18n.language i18n)) (object
      method name   = name
      method status = status
      method pic    = pic
    end) i18n ctx

end

let _add_or_invite = 
  let _any = load "add-or-invite" [
    "add",    Mk.text (#add) ;
    "invite", Mk.text (#invite) ;
  ] `Html in
  function `Fr -> _any

let add_or_invite ~add ~invite ~i18n ctx = 
  to_html (_add_or_invite (I18n.language i18n)) (object
    method add = JsBase.to_event add
    method invite = JsBase.to_event invite
  end) i18n ctx

let _group_denied = 
  let _fr = load "group-denied-fr" [] `Html in
  function `Fr -> _fr

let group_denied ~i18n ctx = 
  to_html (_group_denied (I18n.language i18n)) () i18n ctx

