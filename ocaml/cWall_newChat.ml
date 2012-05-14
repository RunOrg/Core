(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let form = 
  VQuickForm.longinput 
    ~label:(`label "wall.new-chat.request-topic")
    ~required:true
    (fun _ seed -> seed) 
    (fun _ field value -> match value with 
      | Some string -> Ok string
      | None        -> Bad (field,`label "field.required"))
  |> VQuickForm.narrow_wrap ~submit:(`label "send") 
    
let do_create ~ctx ~feed = 
  O.Box.reaction "create-chat-request" begin fun _ bctx _ response ->

    let json     = bctx # json in 
    let form     = Joy.create 
      ~template:form 
      ~i18n:(ctx#i18n) 
      ~source:(Joy.from_post_json json)
    in

    match Joy.result form with 
      | Bad errors ->
	
	let json = Joy.response (Joy.set_errors errors form) in
	return (O.Action.json json response)

      | Ok topic -> 

	let! self = ohm $ ctx # self in 
	let! _    = ohm $ MItem.Create.chat_request 
	  self topic (ctx # iid) (MFeed.Get.id feed) in

	let js = JsCode.seq [
	  Js.Dialog.close ;
	  JsBase.boxRefresh 0.0
	] in

	return (O.Action.javascript js response)
  end

let ask_create ~ctx ~next = 
  O.Box.reaction "ask-chat-request" begin fun _ bctx _ response ->

    let form     = Joy.create form (ctx#i18n) (Joy.empty) in
    let renderer = Joy.render form (bctx # reaction_url next) in   
    let title    = I18n.translate (ctx # i18n) (`label "wall.new-chat.title") in 

    return $ O.Action.javascript (Js.Dialog.create renderer title) response

  end

let create ~ctx ~feed callback = 
  let! do_create  = do_create ~ctx ~feed in
  let! ask_create = ask_create ~ctx ~next:do_create in
  callback ask_create
