(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "me" name
let jsload name = MModel.Template.jsload "me" name

module Loader = MModel.Template.MakeLoader(struct let from = "me" end)

module Network = struct

  (* Editing profiles ---------------------------------------------------------------------- *)

  let _editform =
    let _fr = jsload "network-admin-edit" begin
      []
      |> FInstance.AdminEdit.Form.to_mapping
	  ~prefix: "asso-edit"
	  ~url:    (#url)
	  ~init:   (#init)
	  ~config: (#config)
    end [] `Html in  
    function `Fr -> _fr 
      
  let editform ~uploader ~form_url ~form_init ~i18n ctx = 
    let template = _editform (I18n.language i18n) in 
    to_html template (object
      method url    = form_url
      method init   = form_init
      method config = (object 
	method uploader = uploader i18n
      end)
    end) i18n ctx

  (* Search -------------------------------------------------------------------------------- *)

  module SearchManual = Loader.Html(struct
    type t = unit
    let source    = function `Fr -> "network-search-manual-fr"
    let mapping _ = []
  end)

  module SearchTag = Loader.Html(struct
    type t = <
      url   : string ;
      tag   : string ;
      count : int ;
    > ;;
    let source  _ = "network-search/tags"
    let mapping _ = [
      "url",   Mk.esc (#url) ;
      "tag",   Mk.esc (#tag) ;
      "count", Mk.int (#count) 
    ] 
  end)

  module SearchItemTag = Loader.Html(struct
    type t = <
      url : string ;
      tag : string
    > 
    let source  _ = "network-search/list/tags"
    let mapping _ = [
      "tag", Mk.esc (#tag) ;
      "url", Mk.esc (#url) 
    ]
  end)

  module SearchItem = Loader.Html(struct
    type t = <
      picture : string ;
      url     : string ;
      name    : string ;
      desc    : string ;
      tags    : SearchItemTag.t list
    > ;;
    let source  _ = "network-search/list"
    let mapping l = [
      "pic",  Mk.esc  (#picture) ;
      "url",  Mk.esc  (#url) ;
      "name", Mk.esc  (#name) ;
      "desc", Mk.esc  (#desc) ;
      "tags", Mk.list (#tags) (SearchItemTag.template l) 
    ]
  end)

  module Search = Loader.Html(struct
    type t = <
      list : (string * string) ;
      tags : SearchTag.t list ;
    > ;;
    let source  _ = "network-search"
    let mapping l = [
      "message", Mk.sub  (fun _ -> ()) (SearchManual.template l) ;
      "list",    Mk.html (#list |- O.Box.draw_container) ;
      "tags",    Mk.list (#tags) (SearchTag.template l) ;
    ]
  end)

  (* List ---------------------------------------------------------------------------------- *)
   
  module ListItem = Loader.Html(struct
    type t =  <
      name : string ;
      pic  : string ;
      url  : string ;
    > ;; 
    let source  _ = "assos-list/list"
    let mapping _ = [
      "name", Mk.esc  (#name) ;
      "pic",  Mk.esc  (#pic) ;
      "url",  Mk.esc  (#url) ;
    ]
  end)

  type list_args = <
    list : ListItem.t list ;
    create : string option ;
  >

  module EmptyList = Loader.Html(struct
    type t = list_args
    let source  _ = "assos-list-empty"
    let mapping _ = []
  end)

  module ListCreate = Loader.Html(struct
    type t = string
    let source  _ = "assos-list/create"
    let mapping _ = [ "url", Mk.esc identity ]
  end)

  module List = Loader.Html(struct
    type t = list_args
    let source  _ = "assos-list"
    let mapping l = [
      "create", Mk.sub_or (#create) (ListCreate.template l) (Mk.empty) ;
      "list",   Mk.list_or (#list) (ListItem.template l) (EmptyList.template l) ;
    ]
  end)

  type request_list_args = <
    list : ListItem.t list ;
  >

  module EmptyRequestList = Loader.Html(struct
    type t = request_list_args
    let source  _ = "network-request-empty"
    let mapping _ = []
  end)

  module RequestList = Loader.Html(struct
    type t = request_list_args
    let source  _ = "network-request-list"
    let mapping l = [
      "list",   Mk.list_or (#list) (ListItem.template l) (EmptyRequestList.template l) ;
    ]
  end)

  module MissingRequest = Loader.Html(struct
    type t = unit
    let source  _ = "network-request-missing"
    let mapping _ = []
  end)

  (* Following ----------------------------------------------------------------------------- *)

  module MissingFollow = Loader.Html(struct
    type t = unit
    let source  _ = "network-follow-missing"
    let mapping _ = []
  end)

  module Follow = Loader.Html(struct
    type t = <
      desc      : string ;
      name      : string ;
      picture   : string ;
    > ;;
    let source    = function `Fr -> "network-follow-fr"
    let mapping _ = [
      "pic",       Mk.esc (#picture) ;
      "desc",      Mk.str (#desc |- VText.format) ;
      "name",      Mk.esc (#name) ;
      "bind",      Mk.str (fun _ -> "") ;
    ]
  end)

  module FollowBind = Loader.Text(struct
    type t = <
      pic  : string ;
      name : string
    > ;;
    let source    = function `Fr -> "network-follow-fr/bind"
    let mapping _ = [
      "pic",  Mk.esc (#pic) ;
      "name", Mk.esc (#name) ;
    ]
  end)

  (* Requests ----------------------------------------------------------------------------- *)

  module RequestDetail = Loader.Html(struct
    type t = <
      text      : string ;
      contact   : string ;
      asso      : string ;
      contacted : string ;
      picture   : string ;
    > ;;
    let source    = function `Fr -> "network-request-detail-fr"
    let mapping _ = [
      "pic",       Mk.esc (#picture) ;
      "text",      Mk.str (#text |- VText.format) ;
      "contact",   Mk.esc (#contact) ;
      "asso",      Mk.esc (#asso) ;
      "contacted", Mk.esc (#contacted) ;
      "bind",      Mk.str (fun _ -> "") ;
      "create",    Mk.str (fun _ -> "") ;
    ]
  end)

  module RequestDetailBind = Loader.Text(struct
    type t = <
      pic  : string ;
      name : string
    > ;;
    let source    = function `Fr -> "network-request-detail-fr/bind"
    let mapping _ = [
      "pic",  Mk.esc (#pic) ;
      "name", Mk.esc (#name) ;
    ]
  end)

  module RequestDetailCreate = Loader.Text(struct
    type t = string
    let source    = function `Fr -> "network-request-detail-fr/create"
    let mapping _ = [
      "name", Mk.esc identity
    ]
  end)

  (* Full page ----------------------------------------------------------------------------- *)

  let _full = 
    let _fr = load "assos" [
      "me.assos.content", Mk.html (#box_assos_page) ;
    ] `Html in
    function `Fr -> _fr 

  let full ~box ~i18n ctx = 
    let template = _full (I18n.language i18n) in 
    to_html template (object method box_assos_page = O.Box.draw_container box end) i18n ctx

end

module Account = struct

  let _view = 
    let _fr = load "account-view"  [
      "picture",   Mk.esc (#picture) ;
      "fullname",  Mk.esc (#fullname) ;
      "email",     Mk.esc (#email) ;
      "birthdate", Mk.esc (#birthdate) ;
      "phone",     Mk.esc (#phone) ;
      "cellphone", Mk.esc (#cellphone) ;
      "address",   Mk.esc (#address) ;
      "zipcode",   Mk.esc (#zipcode) ;
      "city",      Mk.esc (#city) ;
      "country",   Mk.esc (#country) ;
      "gender",    Mk.str (#gender) 
    ] `Html in
    function `Fr -> _fr 

  let view ~user ~picture ~i18n ctx = 
    let lang = I18n.language i18n in
    let opt  = function Some s -> s | None -> "" in
    to_html (_view lang) (object
      method picture   = picture
      method fullname  = user # fullname
      method email     = user # email
      method birthdate = opt (BatOption.map (MFmt.date_string lang) (user # birthdate)) 
      method phone     = opt (user # phone)
      method cellphone = opt (user # cellphone)
      method address   = opt (user # address)
      method zipcode   = opt (user # zipcode) 
      method country   = opt (user # country)
      method city      = opt (user # city) 
      method gender    = match user # gender with 
	| None -> ""
	| Some `m -> "<img src='"^VIcon.male^"'/>"
	| Some `f -> "<img src='"^VIcon.female^"'/>"	  
    end) i18n ctx 

  let _edit = 
    let _fr = load "account-edit" begin
      [
	"cancel",  Mk.esc (#cancel) ;
	"email",   Mk.esc (#email) ;
      ] |> FAccount.Edit.Form.to_mapping
	~prefix: "account-edit"
	~url:    (#url)
	~init:   (#init)
	~config: (#config)
    end `Html in
    function `Fr -> _fr 

  let edit ~uploader ~gender ~form_url ~form_init ~cancel ~i18n ~email ctx = 
    let template = _edit (I18n.language i18n) in 
    to_html template (object
      method url     = form_url
      method init    = form_init
      method cancel  = cancel
      method email   = email
      method config  = (object 
	method uploader = uploader i18n
	method gender   = gender   i18n
      end)
    end) i18n ctx 

  let _share_explain = 
    let _fr = load "account-share-explain-fr" [] `Html in
    function `Fr -> _fr

  let share_explain ~i18n ctx = 
    to_html (_share_explain (I18n.language i18n)) () i18n ctx

  let _share = 
    let _fr = load "account-share" begin
      [
	"cancel",        Mk.esc   (#cancel) ;
	"explanation",   Mk.ihtml (#explanation) ;
      ] |> FShare.Config.Form.to_mapping
	~prefix: "share-config"
	~url:    (#url)
	~init:   (#init)
    end `Html in
    function `Fr -> _fr 

  let share ~form_url ~form_init ~cancel ~i18n ctx = 
    let template = _share (I18n.language i18n) in 
    to_html template (object
      method url    = form_url
      method init   = form_init
      method cancel = cancel
      method explanation i18n ctx = share_explain ~i18n ctx
    end) i18n ctx 

  let _receive_explain = 
    let _fr = load "account-receive-explain-fr" [] `Html in
    function `Fr -> _fr

  let receive_explain ~i18n ctx = 
    to_html (_receive_explain (I18n.language i18n)) () i18n ctx

  let _receive = 
    let _fr = load "account-receive" begin
      [
	"cancel",        Mk.esc   (#cancel) ;
	"explanation",   Mk.ihtml (#explanation) ;
      ]	|> FNotification.Receive.Form.to_mapping
	~prefix: "notification-receive"
	~url:    (#url)
	~init:   (#init)
    end `Html in
    function `Fr -> _fr 

  let receive ~form_url ~form_init ~cancel ~i18n ctx = 
    let template = _receive (I18n.language i18n) in 
    to_html template (object
      method url    = form_url
      method init   = form_init
      method cancel = cancel
      method explanation i18n ctx = receive_explain ~i18n ctx
    end) i18n ctx 
      
  let _set_password = 
    let _fr = load "account-password" begin
      []
      |> FAccount.Password.Form.to_mapping 
	~prefix:"setpass-form" 
	~url:  (#url) 
	~init: (#init)
    end `Html in
    
    function `Fr -> _fr

  let set_password ~url ~init ~i18n ctx =   
    to_html (_set_password (I18n.language i18n)) (object 
      method url       = url
      method init      = init
    end) i18n ctx
    
  let _full = 
    let _fr = load "account" [
      "me.account.content", Mk.html (#box_account_page) ;
    ] `Html in
    function `Fr -> _fr 

  let full ~box ~i18n ctx = 
    let template = _full (I18n.language i18n) in 
    to_html template (object method box_account_page = O.Box.draw_container box end) i18n ctx

end

module News = Loader.Html(struct
  type t = string * string
  let source  _ = "news"
  let mapping l = [
    "content", Mk.html O.Box.draw_container 
  ]
end)

module IndexFoot = Loader.Html(struct
  type t = unit
  let source  _ = "index/foot"
  let mapping _ = []
end)

module Index = Loader.Html(struct
  type t = bool
  let source  _ = "index"
  let mapping l =  [
    "content", Mk.html (fun _ -> O.Box.draw_container O.Box.root) ;
    "foot",    Mk.sub_or (function true -> Some () | false -> None) 
      (IndexFoot.template l) Mk.empty
  ]
end)
