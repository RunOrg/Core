(* © 2012 RunOrg *)
  
open Ohm
open BatPervasives
open Ohm.Universal

let form () = 
  Joy.begin_object (fun ~opens ~closes -> 
    (object
      method opens    = opens
      method closes   = closes
     end))

  |> Joy.append (fun f opens -> f ~opens)
      (Joy.seed_map (#opens) 
	 (VQuickForm.fieldOption      
	    ~add:(`label "votes.create.opens-on.add")
	    ~label:(`label "votes.create.opens-on")
	    (VQuickForm.datetime
	       ~label:(`label "")
	       identity)))
      
  |> Joy.append (fun f closes -> f ~closes)
      (Joy.seed_map (#closes) 
	 (VQuickForm.fieldOption      
	    ~add:(`label "votes.create.closes-on.add")
	    ~label:(`label "votes.create.closes-on")
	    (VQuickForm.datetime
	       ~label:(`label "")
	       identity)))

  |> Joy.end_object
  |> VQuickForm.narrow_wrap ~submit:(`label "save") 

let save ~ctx = 
  O.Box.reaction "save" begin fun _ bctx _ response -> 

    let  panic    = return (O.Action.javascript (JsCode.seq [
      Js.Dialog.close ;
      JsBase.boxRefresh 0.0
    ]) response) in
						
    let  json     = bctx # json in 
    let  template = form () in
    let  form     = Joy.create ~template ~i18n:(ctx#i18n) ~source:(Joy.from_post_json json) in
    let  params   = Joy.params form in 

    let! vid      = req_or panic $ IVote.of_json_safe params in 
    let! vote     = ohm_req_or panic $ MVote.try_get ctx vid in 
    let! vote     = ohm_req_or panic $ MVote.Can.admin vote  in

    match Joy.result form with 
      | Bad errors ->
	
	let json = Joy.response (Joy.set_errors errors form) in
	return (O.Action.json json response)

      | Ok data -> 

	let! () = ohm $ MVote.Config.set vote (object
	  method closed_on = data # closes
	  method opened_on = data # opens
	end) in

	let js = JsCode.seq [
	  Js.Dialog.close ;
	  JsBase.boxRefresh 0.0
	] in

	return (O.Action.javascript js response)
  end 

let prepare ~ctx ~save = 
  O.Box.reaction "prepare-save" begin fun _ bctx _ response -> 

    let  panic    = return (O.Action.javascript (JsCode.seq [
      Js.Dialog.close ;
      JsBase.boxRefresh 0.0
    ]) response) in

    let! vid      = req_or panic $ IVote.of_json_safe (bctx # json) in
    let! vote     = ohm_req_or panic $ MVote.try_get ctx vid in 
    let! vote     = ohm_req_or panic $ MVote.Can.admin vote  in

    let  config   = MVote.Config.get vote in

    let source   = Joy.from_seed 
      ~params:(IVote.to_json (IVote.decay vid)) 
      (object
	method opens    = config # opened_on
	method closes   = config # closed_on
       end)
    in

    let form     = Joy.create (form ()) (ctx#i18n) source in
    let renderer = Joy.render form (bctx # reaction_url save) in   
    let title    = I18n.translate (ctx # i18n) (`label "votes.edit") in 

    return $ O.Action.javascript (Js.Dialog.create renderer title) response

  end 

let reaction ~ctx callback = 
  let! save    = save    ~ctx in
  let! prepare = prepare ~ctx ~save in
  callback prepare
    
