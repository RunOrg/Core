(* © 2012 RunOrg *)

open Ohm
open Ohm.Template

let load name = MModel.Template.load "gender" name

let picker = 
  let _template = 
    let _fr = load "picker" [
      "id"   , Mk.esc (fun x -> Id.str (x # id)) ;
      "name" , Mk.esc (#name) ;
    ] `Html in
    function `Fr -> _fr
  in
  let render ~id ~name ~i18n ctx = 
    to_html (_template (I18n.language i18n)) (object
      method id   = id
      method name = name
    end) i18n ctx
  in render


      
