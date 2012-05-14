(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "subscription" name
module Loader = MModel.Template.MakeLoader(struct let from = "subscription" end)

module Forbidden = Loader.Html(struct
  type t = string
  let source    = function `Fr -> "forbidden-fr"
  let mapping _ = [
    "url", Mk.esc identity
  ]
end)

module Workflow = struct

  module NoChoices = Loader.Html(struct
    type t = <
      picture : string ;
      desc    : string ;
      name    : string
    > ;;
    let source     = function `Fr -> "no_choices-fr"
    let mapping  _ = [
      "picture", Mk.esc (#picture) ;
      "desc",    Mk.str (fun x -> VText.format (x # desc)) ;
      "name",    Mk.esc (#name)
    ]
  end)

  let _finish_later = 
    let _fr = load "finish_later-fr" [
      "picture", Mk.esc (#picture) ;
      "name",    Mk.esc (#name) ;
      "url",     Mk.esc (#url) 
    ] `Html in 
    function `Fr -> _fr

  let finish_later ~picture ~name ~url ~i18n ctx = 
    to_html (_finish_later (I18n.language i18n)) (object
      method picture = picture
      method name    = name
      method url     = url
    end) i18n ctx

  let _finish_now = 
    let _fr = load "finish_now-fr" [
      "picture", Mk.esc (#picture) ;
      "name",    Mk.esc (#name) ;
      "url",     Mk.esc (#url) 
    ] `Html in 
    function `Fr -> _fr

  let finish_now ~picture ~name ~url ~i18n ctx = 
    to_html (_finish_now (I18n.language i18n)) (object
      method picture = picture
      method name    = name
      method url     = url
    end) i18n ctx

  module ChooseItem = Loader.Html(struct
    type t = <
      url     : string ;
      name    : I18n.text ;
      summary : I18n.text
    > ;;
    let source  _ = "choose-item"
    let mapping _ = [
      "url",     Mk.esc  (#url) ;
      "name",    Mk.trad (#name) ;
      "summary", Mk.trad (#summary)
    ]
  end)

  module Choose = Loader.Html(struct
    type t = <
      picture : string ;
      desc    : string ;
      name    : string ;
      list    : ChooseItem.t list 
    > ;;
    let source    = function `Fr -> "choose-fr"
    let mapping l = [
      "picture", Mk.esc  (#picture) ;
      "desc",    Mk.str  (fun x -> VText.format (x # desc)) ;
      "name",    Mk.esc  (#name) ;
      "list",    Mk.list (#list) (ChooseItem.template l)
    ]
  end)

  let _form_empty = 
    let _fr = load "form_empty-fr" begin
      [
	"picture", Mk.esc  (#picture) ;
	"name",    Mk.esc  (#name) ;
	"content", Mk.html (#content)
      ] |> FJoin.Form.to_mapping
	~prefix:"join-edit"
	~url:    (#url)
	~init:   (#init)
	~config: (#config) 
	~dynamic:(#dynamic)
    end `Html in
    function `Fr -> _fr

  let form_empty ~content ~form_init ~form_url ~form_config ~form_dynamic ~picture ~name ~i18n ctx = 
    to_html (_form_empty (I18n.language i18n)) (object
      method picture = picture
      method name    = name
      method content = content
      method init    = form_init
      method url     = form_url
      method dynamic = form_dynamic
      method config  = form_config

    end) i18n ctx

  let _form = 
    let _fr = load "form-fr" begin
      [
	"picture", Mk.esc  (#picture) ;
	"name",    Mk.esc  (#name) ;
	"content", Mk.html (#content)
      ] |> FJoin.Form.to_mapping
	~prefix:"join-edit"
	~url:    (#url)
	~init:   (#init)
	~config: (#config) 
	~dynamic:(#dynamic)
    end `Html in
    function `Fr -> _fr

  let form ~content ~form_init ~form_url ~form_config ~form_dynamic ~picture ~name ~i18n ctx = 
    to_html (_form (I18n.language i18n)) (object
      method picture = picture
      method name    = name
      method content = content
      method init    = form_init
      method url     = form_url
      method dynamic = form_dynamic
      method config  = form_config

    end) i18n ctx

end

