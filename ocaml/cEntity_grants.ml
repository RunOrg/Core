(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let form ~ctx = 
  let! access = ohm $ CEntitySearch.entities ~ctx ~label:(`label "")(fun seed -> seed) in
  return (access |> VQuickForm.narrow_wrap ~submit:(`label "save"))

let post_edit ~ctx = 
  O.Box.reaction "post-edit-grants" begin fun self bctx url response -> 

    let  json     = bctx # json in 
    let! template = ohm $ form ~ctx in
    let  form     = Joy.create ~template ~i18n:(ctx#i18n) ~source:(Joy.from_post_json json) in

    match Joy.result form with 
      | Bad errors ->
	
	let json = Joy.response (Joy.set_errors errors form) in
	return (O.Action.json json response)

      | Ok list -> 

	let! () = ohm $ MEntity.set_grants ctx list in 

	let js = JsCode.seq [
	  Js.Dialog.close ;
	  JsBase.boxRefresh 0.0
	] in

	return (O.Action.javascript js response)
    
  end 

let show_edit ~ctx post = 
  O.Box.reaction "edit-grants" begin fun self bctx url response -> 

    let! list     = ohm $ MEntity.All.get_granting ctx in 
    let  ids      = List.map MEntity.Get.id list in 

    let! template = ohm $ form ~ctx in
    let  form     = Joy.create ~template ~i18n:(ctx#i18n) ~source:(Joy.from_seed ids) in

    let renderer = Joy.render form (bctx # reaction_url post) in
    let title    = I18n.translate (ctx # i18n) (`label "grants.edit") in 

    return $ O.Action.javascript (Js.Dialog.create renderer title) response

  end

let edit ~ctx callback = 
  let! post = post_edit ~ctx in
  let! show = show_edit ~ctx post in 
  callback show
