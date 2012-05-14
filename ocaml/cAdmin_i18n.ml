(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open O
open Ohm.Universal

open FAdmin.I18n

let get_i18n () = 
  I18n.source (MModel.I18n.load (Id.of_string "i18n-next-fr") `Fr) 

let () = CAdmin_common.register UrlAdmin.edit_i18n_post begin fun i18n user request response ->
  
  let form = Form.readpost (request # post) in 
  
  let source = ref [] in 
  
  let form = Form.mandatory `Source I18n.Source.fmt source (i18n,`label "") form in 
  
  let _ = form in
  
  let src  = Id.of_string "i18n-next-fr" in
  let dest = Id.of_string "i18n-common-fr" in 
  
  let! () = ohm (MModel.I18n.save src ~volatile:true !source) in
  let! () = ohm (MModel.I18n.copy ~src ~dest) in
  
  return response
    
end   

let () = CAdmin_common.register UrlAdmin.edit_i18n begin fun i18n user request response ->

  let source = get_i18n () in 

  let data = object
    method url  = UrlAdmin.edit_i18n_post # build
    method init = Form.initialize (function `Source -> I18n.Source.to_json source) 
  end in 

  let response = 
    CAdmin_common.layout
      ~title:(View.esc "Traduction")
      ~body:(VAdmin.I18n.render data i18n)
      ~js:(JsCode.seq [])
      response
  in

  return response

end
