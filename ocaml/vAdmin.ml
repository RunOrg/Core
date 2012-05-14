(* © 2012 RunOrg *)
open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "admin" end)

module Index = Loader.Text(struct
  type t = View.text
  let source  _ = "index"
  let mapping _ = [ "script", Mk.text identity ]
end)

module PreConfig = struct

  module Index = struct

    module Template = Loader.Html(struct
      type t = < url : string ; edit : string ; name : I18n.text ; id : string ; kind : MEntityKind.t > ;;
      let source  _ = "preconfig-template"
      let mapping _ = [
	"id",       Mk.esc  (# id) ;
	"url",      Mk.esc  (# url) ;
	"text",     Mk.trad (# name) ;
	"icon",     Mk.esc  (# kind |- VIcon.of_entity_kind) ;
	"edit-url", Mk.esc  (# edit) ;
      ]
    end)

    module Vertical = Loader.Html(struct
      type t = < url : string ; edit : string ; name : I18n.text ; id : string ; archive : bool > ;;
      let source  _ = "preconfig-vertical"
      let mapping _ = [
	"id",   Mk.esc  (# id) ;
	"url",  Mk.esc  (# url) ;
	"text", Mk.trad (# name) ;
	"icon", Mk.esc  (fun x -> if x # archive then VIcon.lightbulb_off else VIcon.lightbulb) ;
	"edit-url", Mk.esc (# edit) ;
      ]
    end)
      
    module Page = Loader.Html(struct
      type t = < 
        verticals : Vertical.t list ; 
        templates : Template.t list ;
	new_template : string ;
	new_vertical : string ;
	new_tmpl_version : string ;
	new_vert_version : string ;
      > ;;
      let source  _ = "preconfig"
      let mapping l = [
	"new-tmpl-version-url", Mk.esc  (# new_tmpl_version) ;
	"new-vert-version-url", Mk.esc  (# new_vert_version) ;
	"new-template-url",     Mk.esc  (# new_template) ;
	"new-vertical-url",     Mk.esc  (# new_vertical) ;
	"templates",            Mk.list (# templates) (Template.template l);
	"verticals",            Mk.list (# verticals) (Vertical.template l);
      ]
    end)
      
  end

  module Template = Loader.Html(struct
    type t = <
      name  : I18n.text ;
      desc  : I18n.text ;
      url   : string ;
      config: FAdmin.Template.Edit.Fields.config ;
      init  : FAdmin.Template.Edit.Form.t
    > ;;
    let source _ = "preconfig-template-edit" 
    let mapping _ = [
      "name", Mk.trad (# name) ;
      "desc", Mk.trad (# desc) 
    ] |> FAdmin.Template.Edit.Form.to_mapping
	~prefix:"template-edit"
	~url:   (# url) 
	~config:(# config)
	~init:  (# init)
  end)

  module Vertical = Loader.Html(struct
    type t = <
      name  : I18n.text ;
      desc  : I18n.text ;
      url   : string ;
      config: FAdmin.Vertical.Edit.Fields.config ;
      init  : FAdmin.Vertical.Edit.Form.t
    > ;;
    let source _ = "preconfig-vertical-edit" 
    let mapping _ = [
      "name", Mk.trad (# name) ;
      "desc", Mk.trad (# desc) 
    ] |> FAdmin.Vertical.Edit.Form.to_mapping
	~prefix:"vertical-edit"
	~url:   (# url) 
	~config:(# config)
	~init:  (# init)
  end)

  module TemplateVersion = struct

    module Checkbox = Loader.Html(struct
      type t = < 
	input : View.html ;
        label : View.html ; 
	kind : MEntityKind.t
      > ;;
      let source  _ = "preconfig-template-version-create-checkbox"
      let mapping _ = [
	"icon",  Mk.esc  (#kind |- VIcon.of_entity_kind) ;
	"input", Mk.html (#input) ;
	"label", Mk.html (#label) 
      ]
    end)

    module Create = Loader.Html(struct
      type t = <
	checkboxes : Checkbox.t list ;
        url        : string ;
	init       : FAdmin.PreConfig.TemplateVersionCreate.Form.t ;
        config     : FAdmin.PreConfig.TemplateVersionCreate.Fields.config ;
	dynamic    : FAdmin.PreConfig.TemplateVersionCreate.Fields.t list ;
      > ;;
      let source  _ = "preconfig-template-version-create"
      let mapping l = [
	"checkboxes", Mk.list (# checkboxes) (Checkbox.template l) ;
      ] |> FAdmin.PreConfig.TemplateVersionCreate.Form.to_mapping
	  ~prefix: "version-create"
	  ~url:    (# url) 
	  ~init:   (# init) 
	  ~config: (# config) 
	  ~dynamic:(# dynamic) 	 
    end)
  end

  module VerticalVersion = struct

    module Checkbox = Loader.Html(struct
      type t = < 
	input : View.html ;
        label : View.html ; 
	archive : bool
      > ;;
      let source  _ = "preconfig-vertical-version-create-checkbox"
      let mapping _ = [
	"icon",  Mk.esc  (fun x -> if x # archive then VIcon.lightbulb_off else VIcon.lightbulb) ;
	"input", Mk.html (#input) ;
	"label", Mk.html (#label) 
      ]
    end)

    module Create = Loader.Html(struct
      type t = <
	checkboxes : Checkbox.t list ;
        url        : string ;
	init       : FAdmin.PreConfig.VerticalVersionCreate.Form.t ;
        config     : FAdmin.PreConfig.VerticalVersionCreate.Fields.config ;
	dynamic    : FAdmin.PreConfig.VerticalVersionCreate.Fields.t list ;
      > ;;
      let source  _ = "preconfig-vertical-version-create"
      let mapping l = [
	"checkboxes", Mk.list (# checkboxes) (Checkbox.template l) ;
      ] |> FAdmin.PreConfig.VerticalVersionCreate.Form.to_mapping
	  ~prefix: "version-create"
	  ~url:    (# url) 
	  ~init:   (# init) 
	  ~config: (# config) 
	  ~dynamic:(# dynamic) 	 
    end)
  end
end

module I18n = Loader.Html(struct
  type t = <
    url  : string ;
    init : FAdmin.I18n.Form.t ;
  > ;;
  let source  _ = "i18n"
  let mapping _ =
    FAdmin.I18n.Form.to_mapping
      ~prefix: "i18n"
      ~url:    (# url) 
      ~init:   (# init)
      []
end)

module MakeAdmin = Loader.Html(struct
  type t = <
    url  : string ;
  > ;;
  let source  _ = "make-admin"
  let mapping _ =
    FAdmin.MakeAdmin.Form.to_mapping
      ~prefix: "make-admin"
      ~url:    (# url) 
      ~init:   (fun x -> FAdmin.MakeAdmin.Form.empty)
      []
end)
  
