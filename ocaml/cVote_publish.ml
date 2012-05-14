(* © 2012 RunOrg *)
  
open Ohm
open BatPervasives
open Ohm.Universal

let form () = 
  Joy.begin_object (fun ~question ~answers ~multi ~opens ~closes ~anonymous -> 
    (object
      method question  = question 
      method answers   = answers
      method multi     = multi
      method opens     = opens
      method closes    = closes
      method anonymous = anonymous
     end))

  |> Joy.append (fun f question -> f ~question)
      (VQuickForm.textarea
	 ~label:(`label "votes.create.question")
	 ~required:true
	 (fun _ seed -> seed # question) 
	 (fun _ field value -> match value with 
	   | Some string -> Ok string
	   | None        -> Bad (field,`label "field.required")))

  |> Joy.append (fun f answers -> f ~answers) 
      (Joy.seed_map (#answers) 
	 (VQuickForm.fieldArray
	    ~add:(`label "votes.create.answers.add")
	    ~label:(`label "votes.create.answers")
	    (VQuickForm.longinput
	       ~label:(`text "")
	       (fun _ seed -> seed) 
	       (fun _ field value -> match value with 
		 | Some string -> Ok string
		 | None        -> Ok ""))))

  |> Joy.append (fun f multi -> f ~multi) 
      (VQuickForm.choice
	 ~format:Fmt.Bool.fmt
	 ~source:[ true,  flip I18n.get (`label "yes") ;
		   false, flip I18n.get (`label "no")  ]
	 ~required:true
	 ~label:(`label "votes.create.multi")
	 ~multiple:false
	 (fun _ init -> if init # multi then [true] else [false])
	 (fun _ field value -> match value with 
	   | [true]  -> Ok true
	   | [false] -> Ok false
	   |  _      -> Bad (field,`label "field.required"))
      )

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

  |> Joy.append (fun f anonymous -> f ~anonymous) 
      (VQuickForm.choice
	 ~format:Fmt.Bool.fmt
	 ~source:[ true,  flip I18n.get (`label "yes") ;
		   false, flip I18n.get (`label "no")  ]
	 ~required:true
	 ~label:(`label "votes.create.anonymous")
	 ~multiple:false
	 (fun _ init -> if init # anonymous then [true] else [false])
	 (fun _ field value -> match value with 
	   | [true]  -> Ok true
	   | [false] -> Ok false
	   |  _      -> Bad (field,`label "field.required"))
      )

  |> Joy.end_object
  |> VQuickForm.narrow_wrap ~submit:(`label "create") 


let publish ~ctx ~entity = 
  O.Box.reaction "publish" begin fun _ bctx _ response -> 

    let  json     = bctx # json in 
    let  template = form () in
    let  form     = Joy.create ~template ~i18n:(ctx#i18n) ~source:(Joy.from_post_json json) in
    
    match Joy.result form with 
      | Bad errors ->
	
	let json = Joy.response (Joy.set_errors errors form) in
	return (O.Action.json json response)

      | Ok data -> 

	let! () = ohm $ MVote.create 
	  ~ctx 
	  ~owner:(`entity entity) 
	  ~config:(object
	    method closed_on = data # closes
	    method opened_on = data # opens
	  end)
	  ~question:(object
	    method question = `text (data # question)
	    method answers  = List.map (fun x -> `text x) (data # answers)
	    method multiple = data # multi
	  end)
	  ~anonymous:(data # anonymous) 
	in

	let js = JsCode.seq [
	  Js.Dialog.close ;
	  JsBase.boxRefresh 0.0
	] in

	return (O.Action.javascript js response)
  end 

let prepare ~ctx ~publish = 
  O.Box.reaction "prepare-publish" begin fun _ bctx _ response -> 

    let source   = Joy.from_seed (object
      method question  = "" 
      method opens     = None
      method closes    = None
      method answers   = [
	I18n.translate (ctx # i18n) (`label "votes.aye") ;
	I18n.translate (ctx # i18n) (`label "votes.nay") ;
	I18n.translate (ctx # i18n) (`label "votes.abstain")
      ]
      method multi     = false
      method anonymous = false
    end) in

    let form     = Joy.create (form ()) (ctx#i18n) source in
    let renderer = Joy.render form (bctx # reaction_url publish) in   
    let title    = I18n.translate (ctx # i18n) (`label "votes.create") in 

    return $ O.Action.javascript (Js.Dialog.create renderer title) response

  end 

let reaction ~ctx ~(entity:[`Admin] MEntity.t option) callback =
  match entity with None -> callback None | Some entity -> 
    let! publish = publish ~ctx ~entity in
    let! prepare = prepare ~ctx ~publish in
    callback (Some prepare) 
