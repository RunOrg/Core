(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "lists" name

module Fields = struct

  let type_name (t : MJoinFields.FieldType.t) = 
    `label begin match t with 
      | `textarea   -> "field.type.textarea"
      | `date       -> "field.type.date"
      | `longtext   -> "field.type.longtext"
      | `checkbox   -> "field.type.checkbox"
      | `pickOne  _ -> "field.type.pickOne"
      | `pickMany _ -> "field.type.pickMany"
    end

  let required req = 
    if List.mem `required req then "<img src='/public/icon/star.png'/>" else ""     

  let _explain = 
    let _fr = load "fields-list-help-fr" [] `Html in
    function `Fr -> _fr

  let explain i18n ctx = 
    to_html (_explain (I18n.language i18n)) () i18n ctx

  let _item = 
    let _fr = load "fields-list-item" [
      "name",     Mk.trad (#label) ;
      "type",     Mk.trad (#edit |- type_name) ;
      "required", Mk.str  (#valid |- required) 
    ] `Html in 
    function `Fr -> _fr

  let _list = 
    let _fr = load "fields-list" [
      "help",  Mk.ihtml (#help) ;
      "edit",  Mk.esc   (#edit) ;
      "list",  Mk.list  (#list) (_item `Fr) ;	
    ] `Html in 
    function `Fr -> _fr

  let list ~url_edit ~(fields:MJoinFields.Field.t list) ~i18n ctx = 
    to_html (_list (I18n.language i18n)) (object
      method help = explain 
      method list = fields
      method edit = url_edit 
    end) i18n ctx

  let _field = 
    let _fr = load "fields-field" [
      "id",       Mk.esc  (#id |- Id.str) ;
      "name",     Mk.trad (#field |- (#label)) ;
      "type",     Mk.trad (#field |- (#edit) |- type_name) ;
      "data",     Mk.esc  (#json) ;
      "edit",     Mk.text (#edit) ;
      "required", Mk.str (#field |- (#valid) |- required)
    ] `Html in 
    function `Fr -> _fr
      
  let field ~url_edit ~field ~i18n ctx = 
    let id   = Id.gen () in
    let json = Json_io.string_of_json ~compact:true ~recursive:true (MJoinFields.Field.to_json field) in
    let args = Json_type.Build.objekt ["edit",Json_type.Build.string json] in
    to_html (_field (I18n.language i18n)) (object
      method id    = id
      method field = field
      method json  = json
      method edit  = JsBase.to_event (Js.runFromServer ~args (url_edit id))
    end) i18n ctx
      
  let _page = 
    let _fr = load "fields-form" [
      "save",   Mk.text (#save) ;
      "cancel", Mk.esc  (#cancel) ;
      "id",     Mk.esc  (#id |- Id.str) ;
      "add",    Mk.text (#add) ;
      "list",   Mk.list (#list) (_field `Fr) ;	
    ] `Html in 
    function `Fr -> _fr
      
  let page ~list_id ~url_save ~url_add ~url_cancel ~url_edit ~(fields:MJoinFields.Field.t list) ~i18n ctx = 
    to_html (_page (I18n.language i18n)) (object
      method id     = list_id
      method save   = JsBase.to_event (Js.sendList list_id url_save)
      method list   = List.map (fun f -> 
	let id   = Id.gen () in
	let json = Json_io.string_of_json ~compact:true ~recursive:true (MJoinFields.Field.to_json f) in
	let args = Json_type.Build.objekt ["edit",Json_type.Build.string json] in
	(object
	  method id    = id
	  method field = f
	  method json  = json
	  method edit  = JsBase.to_event (Js.runFromServer ~args (url_edit id))
	 end)) fields
      method cancel = url_cancel
      method add    = JsBase.to_event (Js.runFromServer url_add)
    end) i18n ctx
    |> View.Context.add_js_code (Js.sortable list_id (Id.of_string "") "sort-placeholder")	
          
  module Edit = struct

    let _required = 
      let _fr = load "fields-field-edit-required" [
	"input", Mk.html (#input) ;
	"label", Mk.html (#label) 
      ] `Html
      in
      function `Fr -> _fr

    let required dyn i18n ctx = 
      to_html (_required (I18n.language i18n)) (object
	method input = dyn # input `Required 
	method label = dyn # label `Required
      end) i18n ctx

    let _choice = 
      let _fr = load "fields-field-edit-choice" [
	"input.0", Mk.html (fun x -> x # input 0) ;
	"input.1", Mk.html (fun x -> x # input 1) ;
	"input.2", Mk.html (fun x -> x # input 2) ;
	"input.3", Mk.html (fun x -> x # input 3) ;
	"input.4", Mk.html (fun x -> x # input 4) ;
	"input.5", Mk.html (fun x -> x # input 5) ;
	"input.6", Mk.html (fun x -> x # input 6) ;
	"input.7", Mk.html (fun x -> x # input 7) ;
	"label",   Mk.html (fun x -> x # label 0) ;
      ] `Html
      in
      function `Fr -> _fr

    let choice dyn i18n ctx = 
      to_html (_choice (I18n.language i18n)) (object
	method input n = dyn # input (`Choice n)
	method label n = dyn # label (`Choice n)
      end) i18n ctx
      
    let _form = 
      let _fr = load "fields-field-edit" begin
	[ "more", Mk.ihtml (#more) ]
	|> FField.Edit.Form.to_mapping
	  ~prefix: "edit-field"
	  ~url:    (#url)
	  ~init:   (#init)
	  ~dynamic:(#dynamic)
      end `Html in
      function `Fr -> _fr
	
    let form ~url ~init ~dynamic ~blocks ~i18n ctx = 
      let dyn = new FField.Edit.Form.dyn () i18n in 
      to_html (_form (I18n.language i18n)) (object
	method url  = url
	method init = init
	method dynamic = dynamic 
	method more i c = View.foreach begin function 
	  | `Required -> required dyn i
	  | `Choice   -> choice   dyn i 
	end blocks c
      end) i18n ctx
	
  end
    
end

module Edit = struct

  module AddRem = struct

    let _column = 
      let _fr = load "cols-addrem-column" [
	"name",   Mk.esc (#name) ;
	"source", Mk.esc (#source) ;
	"show",   Mk.str (fun x -> if x # show then "<img src='/public/icon/tick.png'/>" else "") ;
	"data",   Mk.esc (#data |- Json_io.string_of_json ~compact:true ~recursive:true) ;
      ] `Html in 
      function `Fr -> _fr

    let column ~name ~source ~show ~data ~i18n ctx = 
      to_html (_column (I18n.language i18n)) (object
	method name   = name
	method source = source
	method show   = show
	method data   = data
      end) i18n ctx

    type column = <	
      name   : string ;
      source : string ;
      show   : bool ;
      data   : Json_type.t 
    >

    let _page = 
      let _fr = load "cols-addrem-form" [
	"save",   Mk.text (#save) ;
	"id",     Mk.esc  (#id |- Id.str) ;
	"add",    Mk.text (#add) ;
	"cancel", Mk.esc  (#cancel) ;
	"list",   Mk.list (#list) (_column `Fr) ;	
      ] `Html in 
      function `Fr -> _fr
	
    let page ~url_save ~url_cancel ~url_add ~(columns:column list) ~i18n ctx = 
      let id = Id.gen () in
      to_html (_page (I18n.language i18n)) (object
	method id     = id
	method save   = JsBase.to_event (Js.sendList id url_save)
	method cancel = url_cancel
	method list   = columns
	method add    = JsBase.to_event (Js.runFromServer (url_add id))
      end) i18n ctx
	
  end

  module Summary = struct
      
    type column = < 
      num    : int ;
      name   : string ;
      source : string ;
      show   : bool
    > ;;

    let _column = 
      let _fr = load "cols-column" [
	"num",    Mk.int (#num) ;
	"name",   Mk.esc (#name) ;
	"source", Mk.esc (#source) ;
	"show",   Mk.str (fun x -> if x # show then "<img src='/public/icon/tick.png'/>" else "") ;
      ] `Html in
      function `Fr -> _fr
    
    let _columns = 
      let _fr = load "cols-summary" [
	"list",   Mk.list (#content) (_column `Fr) ;
	"addrem", Mk.esc  (#addrem) ;
	"edit",   Mk.esc  (#edit) 
      ] `Html in
      function `Fr -> _fr
      
    let columns ~(list:column list) ~url_addrem ~url_edit ~i18n ctx =
      to_html (_columns (I18n.language i18n)) (object
	method content = list
	method addrem  = url_addrem
	method edit    = url_edit
      end) i18n ctx

  end

  module Order = struct

    let _column = 
      let _fr = load "cols-order-column" [
	"id",          Mk.esc  (#list |- Id.str) ;
	"num",         Mk.int  (#num) ;
	"label.input", Mk.html (fun x -> x # dyn # input (`Label (x # num))) ;
	"show.input",  Mk.html (fun x -> x # dyn # input (`Show  (x # num))) ; 
	"show.label",  Mk.html (fun x -> x # dyn # label (`Show  (x # num))) ;
	"source",      Mk.esc  (#source) ;
      ] `Html in
      function `Fr -> _fr

    let columns 
	~config
	~list
	~columns
	~i18n
	ctx = 
      let template = _column (I18n.language i18n) in
      let dyn = new FColumn.Order.Form.dyn config i18n  in     
      View.concat (List.map begin fun (num,source) ->
	to_html template (object
	  method dyn    = dyn
	  method num    = num
	  method list   = list 
	  method source = source
	end) i18n
      end columns) ctx
      
    let _form = 
      let _fr = load "cols-order-form" begin
	[
	  "content",   Mk.ihtml (#content) ;
	  "cancel",    Mk.esc   (#cancel) ;
	  "id",        Mk.esc   (#id |- Id.str) ;
	] |> FColumn.Order.Form.to_mapping
	  ~prefix: "column-order"
	  ~url:    (#url)
	  ~init:   (#init)
	  ~config: (#config)
	  ~dynamic:(#dynamic) 
      end `Html in
      function `Fr -> _fr

    let form 
	~url
	~cancel
	~init
	~config
	~id 
	~content
	~dynamic
	~i18n
	ctx = 
      to_html (_form (I18n.language i18n)) (object
	method url     = url
	method init    = init
	method config  = config
	method content = content
	method dynamic = dynamic
	method cancel  = cancel
	method id      = id
      end) i18n ctx
      |> View.Context.add_js_code (JsCode.seq [
	Js.sortable id (FColumn.Order.Form.id `Order) "sort-placeholder" ;
	Js.setTrigger FColumn.Order.trigger (Js.redirect cancel)
      ])	
          
  end

end

