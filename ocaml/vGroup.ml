(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "group" name

module Link = struct

  let _link = 
    let _fr = load "link-item" [
      "id",     Mk.esc  (#id |- Id.str) ;
      "remove", Mk.text (#remove |- JsBase.to_event) ;
      "source", Mk.trad (#source)
    ] `Html in 
    function `Fr -> _fr
      
  let link ~remove ~id ~source ~i18n ctx = 
    to_html (_link (I18n.language i18n)) (object
      method id     = id
      method source = source
      method remove = remove 
    end) i18n ctx
      
  type item = <
    id     : Id.t ;
    remove : JsCode.t ;
    source : I18n.text  
  >

  let _info = 
    let _fr = load "link-desc-fr" [
      "current", Mk.trad (#current)
    ] `Html in
    function `Fr -> _fr

  let info current i18n ctx = 
    to_html (_info (I18n.language i18n)) (object
      method current = current
    end) i18n ctx

  let _page = 
    let _fr = load "link-list" [
      "id",      Mk.esc   (#id |- Id.str) ;
      "add",     Mk.text  (#add |- JsBase.to_event) ;
      "list",    Mk.list  (#list) (_link `Fr) ;	
      "explain", Mk.ihtml (#current |- info) 
    ] `Html in 
    function `Fr -> _fr
      
  let page ~id ~url_add ~current ~links ~i18n ctx = 
    to_html (_page (I18n.language i18n)) (object
      method id      = id
      method list    = (links : item list)
      method add     = Js.runFromServer url_add
      method current = current
    end) i18n ctx
      
end
