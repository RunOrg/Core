(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives
open O

module Download : sig

  val reaction :
       ctx:'any CContext.full
    -> where:MAccountLine.where
    -> (Box.reaction -> 'url O.box) -> 'url O.box

end = struct

  let render_line i18n (id,line) = 
    let! who = ohm (
      match line.MAccountLine.Data.payer with None -> return "" | Some avatar ->
	MAvatar.details avatar |> Run.map (CName.get i18n)
    ) in
	
    return MAccountLine.Data.([
      I18n.translate i18n line.what ;
      who ;				
      VDate.day_render line.paid i18n ;
      VMoney.print (if line.direction = `In then line.amount else - line.amount) ;
      if line.canceled = None then "" else 
	I18n.translate i18n (`label "payment.canceled") 
    ])

  let reaction ~ctx ~where = 
    O.Box.reaction "download" begin fun self bctx _ response ->

      let! lines = ohm $ MAccountLine.get_all where in
      let! rendered_lines = ohm $ Run.list_map (render_line (ctx # i18n)) lines in
      
      let data = OhmCsv.to_csv [] rendered_lines in
      
      return (Action.file ~file:"list.csv" ~mime:"text/csv" ~data response)
    
    end

end

module Summary : sig

  val box : 
       ctx:'any CContext.full 
    -> where:MAccountLine.where
    -> ('prefix * CSegs.accounting_page) O.box

end = struct

  let render_line ctx bctx prefix (id,line) = 

    let! who = ohm (
      match line.MAccountLine.Data.payer with None -> return "" | Some avatar ->
	MAvatar.details avatar |> Run.map (CName.get (ctx#i18n))
    ) in

    let url = 
      UrlR.build (ctx#instance) (bctx # segments) (prefix,`View (IAccountLine.decay id)) 
    in
	  
    return MAccountLine.Data.(object
      method details   = line.what
      method who       = who
      method url       = url
      method date      = line.paid 
      method amount    = line.amount
      method direction = line.direction
      method canceled  = line.canceled <> None
    end)

  let box ~ctx ~where = 
    let! download = Download.reaction ~ctx ~where in
    O.Box.leaf begin fun bctx (prefix,_) ->
      
      let! totals = ohm $ MAccountLine.totals  where in
      let! lines  = ohm $ MAccountLine.get_all where in
      let! rendered_lines = ohm $ Run.list_map (render_line ctx bctx prefix) lines in

      let data = object
	method new_in    = UrlR.build (ctx # instance) (bctx # segments) (prefix, `NewIn)
	method new_out   = UrlR.build (ctx # instance) (bctx # segments) (prefix, `NewOut)
	method download  = bctx # reaction_url download 
	method out_total = totals # total_out
	method in_total  = totals # total_in
	method lines     = rendered_lines
      end in
      
      return (VAccounting.Page.render data (ctx#i18n)) 
    end

end

module Cancel = struct

  let reaction ~ctx ~where ~id = 
    O.Box.reaction "cancel" begin fun _ bctx _ response ->

      let! self = ohm $ ctx # self in
      let! ()   = ohm $ MAccountLine.cancel where id (Some self) in

      let! details = ohm $ MAvatar.details self in
      let  name    = CName.get (ctx#i18n) details in 

      let data = object
	method canceled = Unix.gettimeofday () 
	method canceler = Some name
      end in

      let view = VAccounting.DetailPage_Canceled.render data (ctx # i18n) in
      return $ Action.javascript (Js.replaceOtherWith "#cancel-me" view) response

    end 
    |> CConfirm.ask ctx (`label "accounting.cancel.confirm")

end

module Edit = struct

  let form ctx cancel_url = 
    Joy.begin_object (fun ~what ~reference ~comment ->
      (object
	method what      = what
	method reference = reference
	method comment   = comment
       end))

    |> Joy.append (fun f  what -> f ~what) 
	(VQuickForm.longinput
	   ~label:(`label "accounting.new.reason")
	   ~required:true
	   (fun _ init -> init # what)
	   (fun _ field value -> match value with 
	     | Some string -> Ok string
	     | None -> Bad (field,`label "field.required")
	   )
	)

    |> Joy.append (fun f reference -> f ~reference) 
	(VQuickForm.longinput
	   ~label:(`label "accounting.new.reference")
	   ~minitip:(`label "accounting.new.reference.minitip")
	   (fun _ init -> init # reference) 
	   (fun _ _ value -> Ok value)
	)

    |> Joy.append (fun f comment -> f ~comment) 
	(VQuickForm.textarea
	   ~label:(`label "accounting.new.comment")
	   (fun _ init -> init # comment) 
	   (fun _ _ value -> Ok (BatOption.default "" value))
	)

    |> Joy.end_object 
    |> VQuickForm.wrap 
	~submit:(`label "edit")
	~cancel:(`label "back", cancel_url) 

  let action ~ctx ~where ~id = 
    O.Box.reaction "edit" begin fun self bctx (prefix,_) response ->

      let source = Joy.from_post_json (bctx#json) in

      let back = UrlR.build (ctx#instance) (bctx#segments) (prefix,`Summary) in
      let form = Joy.create ~template:(form ctx back) ~i18n:(ctx#i18n) ~source in 

      match Joy.result form with
	| Bad errors ->

	  let json = Joy.response (Joy.set_errors errors form) in
	  return $ Action.json json response

	| Ok result ->

	  let! self = ohm $ ctx # self in

	  let! () = ohm (
	    MAccountLine.update where id
	      ~who:(Some self) 
	      ~what:(`text (result # what))
	      ~reference:(result # reference)
	      ~comment:(result # comment)
	  ) in
	  
	  return $ Action.javascript (Js.redirect back) response
      
    end

end

module New = struct

  let form ctx direction cancel_url = 
    let! view_contacts = ohm $ MInstanceAccess.can_view_directory ctx in
    return begin
      Joy.begin_object (fun ~what ~amount ~date ~mode ~payer ~reference ~comment ->
	(object
	  method amount    = amount
	  method date      = date
	  method what      = what
	  method mode      = mode
	  method reference = reference
	  method comment   = comment
	  method payer     = payer
	 end))
	
      |> Joy.append (fun f  what -> f ~what) 
	  (VQuickForm.longinput
	     ~label:(`label "accounting.new.reason")
	     ~required:true
	     (fun _ init -> init # reason)
	     (fun _ field value -> match value with 
	       | Some string -> Ok string
	       | None -> Bad (field,`label "field.required")
	     )
	  )
	  
      |> Joy.append (fun f amount -> f ~amount) 
	  (VQuickForm.input
	     ~label:(`label "accounting.new.amount")
	     ~required:true
	     (fun i18n init -> MFmt.format_amount (I18n.language i18n) (init # amount))
	     (fun i18n field value -> match value with
	       | None -> Bad (field,`label "field.required")
	       | Some string ->
		 match MFmt.unformat_amount (I18n.language i18n) string with 
		   | Some amount ->
		     if amount > 0 then Ok amount
		     else Bad (field,`label "accounting.amount.error")
		   | None -> Bad (field,`label "accounting.amount.error"))	
	  )
	  
      |> Joy.append (fun f date -> f ~date) 
	  (VQuickForm.date
	     ~label:(`label "accounting.new.date")
	     ~minitip:(`label "accounting.new.date.minitip")
	     ~required:true
	     (fun _ init -> init # date) 
	     (fun _ field value -> match value with
	       | Some date -> Ok date
	       | None -> Bad (field,`label "field.required")
	     )
	  )
	  
      |> Joy.append (fun f mode -> f ~mode) 	
	  (VQuickForm.select 
	     ~format:MAccountLine.Method.fmt
	     ~source:(`Static (List.map (fun m ->
	       m, VLabel.of_payment_method m, None
	     ) MAccountLine.all_methods))
	     ~required:true
	     ~label:(`label "accounting.new.method")
	     (fun _ init -> Some (init # mode))
	     (fun _ field value -> match value with 
	       | Some mode -> Ok mode
	       | None -> Bad (field,`label "field.required"))
	  )
	  
      |> Joy.append (fun f payer -> f ~payer) 
	  (match view_contacts with
	    | None -> Joy.constant None
	    | Some iid -> 
	      CMember.Picker.configure iid ~ctx 
		(fun ~format ~source ->
		  VQuickForm.select ~format ~source
		    ~label:(match direction with 
		      | `In  -> `label "accounting.new.payer.in"
		      | `Out -> `label "accounting.new.payer.out")
		    (fun _ init -> Some (init # payer))
		    (fun _ field value -> Ok value))
	  )
	  
      |> Joy.append (fun f reference -> f ~reference) 
	  (VQuickForm.longinput
	     ~label:(`label "accounting.new.reference")
	     ~minitip:(`label "accounting.new.reference.minitip")
	     (fun _ init -> init # reference) 
	     (fun _ _ value -> Ok value)
	  )
	  
      |> Joy.append (fun f comment -> f ~comment) 
	  (VQuickForm.textarea
	     ~label:(`label "accounting.new.comment")
	     (fun _ init -> init # comment) 
	     (fun _ _ value -> Ok (BatOption.default "" value))
	  )
	  
      |> Joy.end_object 
      |> VQuickForm.wrap 
	  ~submit:(`label "create")
	  ~cancel:(`label "cancel", cancel_url) 
    end

  let action ~ctx ~where direction = 
    let name = "new-"^(match direction with `In -> "in" | `Out -> "out") in
    O.Box.reaction name begin fun self bctx (prefix,_) response ->

      let source = Joy.from_post_json (bctx#json) in
      
      let  back     = UrlR.build (ctx#instance) (bctx#segments) (prefix,`Summary) in
      let! template = ohm $ form ctx direction back in
      let  form     = Joy.create ~template ~i18n:(ctx#i18n) ~source in 

      match Joy.result form with
	| Bad errors ->

	  let json = Joy.response (Joy.set_errors errors form) in
	  return $ Action.json json response

	| Ok result ->

	  let! self = ohm $ ctx # self in

	  let! id, data = ohm $ MAccountLine.create
	      ~subscribe:false
	      ~where
	      ~mode:(result # mode)
	      ~direction
	      ~amount:(result # amount)
	      ~time:(result # date)
	      ~what:(`text (result # what))
	      ~join:false
	      ~payer:(result # payer)
	      ~creator:(Some self)
	      ~reference:(result # reference)
	      ~comment:(result # comment)
	  in
	  
	  let url = 
	    UrlR.build (ctx#instance) (bctx # segments) (prefix,`Summary)
	  in

	  return $ Action.javascript (Js.redirect url) response
      
    end

end

let new_box ~ctx ~where direction = 
  let! create  = New.action ~ctx ~where direction in
  O.Box.leaf begin fun bctx (prefix,_) ->

    let  cancel   = UrlR.build (ctx#instance) (bctx#segments) (prefix,`Summary) in
    let! template = ohm $ New.form ctx direction cancel in
    let  form     = Joy.create template (ctx#i18n) (Joy.empty) in
    
    let renderer i18n ctx = Joy.render form (bctx # reaction_url create) ctx in
    
    return $
      VAccounting.CreatePage.render (object
	method content = renderer
	method title = `label (match direction with 
	  | `In  -> "accounting.new.title.in"
	  | `Out -> "accounting.new.title.out")
      end) (ctx#i18n)
      
  end

let detail_box ~ctx ~(where:MAccountLine.where) ~id = 

  let! cancel = Cancel.reaction ~ctx ~where ~id in
  let! edit   = Edit.action     ~ctx ~where ~id in

  O.Box.leaf begin fun bctx (prefix,_) ->
    let fail = return identity in
    let! _, line = ohm_req_or fail $ MAccountLine.try_get where id in

    let get_name = function
      | None -> return None
      | Some avatar ->
	let! details = ohm $ MAvatar.details avatar in
	return $ Some (CName.get (ctx#i18n) details)
    in

    let! payer    = ohm $ get_name line.MAccountLine.Data.payer in
    let! creator  = ohm $ get_name line.MAccountLine.Data.creator in
    let! canceler = ohm $
      get_name (BatOption.bind fst line.MAccountLine.Data.canceled)
    in

    let cancelurl = bctx # reaction_url cancel in

    let back = UrlR.build (ctx#instance) (bctx#segments) (prefix,`Summary) in
    let form = 
      Joy.create (Edit.form ctx back) (ctx#i18n)
	(Joy.from_seed 
	   MAccountLine.Data.(object
	     method reference = BatOption.default "" line.reference
	     method comment   = line.comment
	     method what      = I18n.translate (ctx#i18n) line.what
	   end))
    in
    
    let renderer i18n ctx = Joy.render form (bctx # reaction_url edit) ctx in
    
    return (VAccounting.DetailPage.render MAccountLine.Data.(object
      method direction = line.direction
      method amount    = line.amount
      method what      = line.what
      method date      = line.paid
      method mode      = line.mode
      method canceled  = BatOption.map snd line.canceled
      method cancelurl = if line.canceled = None then Some cancelurl else None
      method canceler  = canceler
      method payer     = payer
      method creator   = creator
      method created   = line.created
      method form      = renderer
    end) (ctx # i18n))
      
  end

let root_box ~ctx ~(where:MAccountLine.where) = 
  O.Box.decide begin fun _ (_,seg) ->
    match seg with 
      | `Summary -> return (Summary.box ~ctx ~where)
      | `NewIn   -> return (new_box     ~ctx ~where `In)
      | `NewOut  -> return (new_box     ~ctx ~where `Out)
      | `View id -> return (detail_box  ~ctx ~where ~id)
  end
  |> O.Box.parse CSegs.accounting_pages

let entity_tab ~ctx ~(entity:[`Admin] MEntity.t) = 
  let child = "c" in
  let where = `Entity (MEntity.Get.id entity, MEntity.Get.instance entity) in
  O.Box.node begin fun bctx url ->
    return [child, root_box ~ctx ~where], 
    return (VAccounting.TabPage.render (Box.draw_container (bctx#name,child)) (ctx # i18n))
  end

let instance_home ~ctx = 
  match IIsIn.Deduce.is_admin (ctx # myself) with
    | None -> O.Box.leaf begin fun _ _ -> 
      return (VCore.admin_only ~i18n:(ctx # i18n))
    end
    | Some isin ->
      let ctx = CContext.evolve_full isin ctx in 
      let where = `Instance (IIsIn.instance isin) in       
      root_box ~ctx ~where
