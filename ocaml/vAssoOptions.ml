(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "assoOptions" name

module Loader = MModel.Template.MakeLoader(struct let from = "assoOptions" end)

let _home_page = 
  let _fr = load "head" [
    "content" , Mk.html (#content |- O.Box.draw_container)
  ] `Html in
  function `Fr -> _fr

let home_page ~content ~i18n ctx = 
  to_html (_home_page (I18n.language i18n)) (object
    method content = content
  end) i18n ctx

let _editform =
  let _fr = load "edit" begin
    []
    |> FInstance.Edit.Form.to_mapping
      ~prefix: "asso-edit"
      ~url:    (#url)
      ~init:   (#init)
      ~config: (#config)
  end `Html in  
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
    
