(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Template
open BatPervasives

let load name = MModel.Template.load "file" name
module Loader = MModel.Template.MakeLoader(struct let from = "file" end)

module Forbidden = Loader.Html(struct
  type t = unit
  let source = function `Fr -> "forbidden-fr"
  let mapping _ = []
end)

module Error = Loader.Html(struct
  type t = unit
  let source = function `Fr -> "error-fr"
  let mapping _ = []
end)

module Excess = Loader.Html(struct
  type t = float * float
  let source = function `Fr -> "excess-fr"
  let mapping _ = [
    "used", Mk.itext (fst |- VFilesize.render) ;
    "free", Mk.itext (snd |- VFilesize.render) ;
  ]
end)

module UploadForm = Loader.Html(struct
  type t = < 
    inner : View.html ;
    cancel : string 
  > ;;
  let source  _ = "upload/form"
  let mapping _ = [
    "inner",  Mk.html (#inner) ;
    "cancel", Mk.esc  (#cancel) 
  ]
end)

module Upload = Loader.Html(struct
  type t = < 
    cancel : string ;
    formats : string list ;
    upload : ConfigS3.upload
  > ;;
  let source  _ = "upload"
  let mapping _ = [
    "form", Mk.ihtml (fun x i ->
      ConfigS3.upload_form (x # upload) (x # formats) 
	(fun inner -> 
	  UploadForm.render (object
	    method inner = inner
	    method cancel = x # cancel
	  end) i))
  ]
end)

let form ~cancel ~formats ~upload ~i18n ctx = 
  Upload.render (object
    method cancel = cancel 
    method formats = formats
    method upload = upload
  end) i18n ctx

let pic_uploader = 
  let _template = 
    let mapping = [
      "id"   , Mk.esc (#id |- Id.str) ;
      "name" , Mk.esc (#name) ;
    ] in
    let _fr = load "picUploader" mapping `Html in
    function `Fr -> _fr 
  in
  let render ~url_put ~url_get ~id ~name ~i18n ctx = 
    let template = _template (I18n.language i18n) in
    let title    = I18n.translate i18n (`label "picUploader.title") in
    let js = Js.picUploader id url_get url_put title in 
    to_html template (object
      method id   = id
      method name = name
    end) i18n (View.Context.add_js_code js ctx) 
  in render

