(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module ViewFmt = Fmt.Make(struct
  type json t = [`Private|`Public]
end)

let view_source = 
  List.map (fun (key,label) ->
    key, (fun i18n -> I18n.get i18n (`label label))
  ) [ `Private , "access.normal" ;
      `Public  , "access.public"  ]
    
let unbound_form cancel_url = 
  Joy.begin_object (fun ~name ~site ~access ->
    (object
      method name        = name
      method site        = site
      method access      = access
     end))
	
      |> Joy.append (fun f name -> f ~name) 
	  (VQuickForm.longinput
	     ~label:(`label "network.field.name")	     
	     ~required:true
	     (fun _ init -> init # name)
	     (fun _ field value -> match value with 
	       | Some string -> Ok string
	       | None -> Bad (field,`label "field.required")
	     )
	  )
	  	  
      |> Joy.append (fun f site -> f ~site) 
	  (VQuickForm.longinput
	     ~label:(`label "network.field.site")
	     ~minitip:(`label "network.field.site.tip")
	     (fun _ init -> BatOption.default "" init # site)
	     (fun _ field value -> Ok value)
	  )

      |> Joy.append (fun f access -> f ~access) 
	(VQuickForm.choice
	   ~format:ViewFmt.fmt
	   ~source:view_source
	   ~multiple:false
	   ~required:true
	   ~label:(`label "network.field.access")
	   (fun _ init -> [init # access])
	   (fun _ field value -> match value with 
	     | [`Public]  -> Ok `Public
	     | [`Private] -> Ok `Private
	     | _          -> Bad (field,`label "field.required")))
	  
      |> Joy.end_object 
      |> Joy.wrap Joy.here (VNetwork.Edit.render (object
	method back = cancel_url
      end))

let bound_form cancel_url = 
  Joy.begin_object (fun ~access ->
    (object
      method access      = access
     end))
	  
      |> Joy.append (fun f access -> f ~access) 
	(VQuickForm.choice
	   ~format:ViewFmt.fmt
	   ~source:view_source
	   ~multiple:false
	   ~required:true
	   ~label:(`label "network.field.access")
	   (fun _ init -> [init # access])
	   (fun _ field value -> match value with 
	     | [`Public]  -> Ok `Public
	     | [`Private] -> Ok `Private
	     | _          -> Bad (field,`label "field.required")))
	  
      |> Joy.end_object 
      |> Joy.wrap Joy.here (VNetwork.Edit.render (object
	method back = cancel_url
      end))

let save ~ctx rid bound = 
  O.Box.reaction "post" begin fun self bctx (prefix,_) response -> 
    
    let back   = UrlR.build (ctx # instance) (bctx # segments) (prefix,`List) in
    let source = Joy.from_post_json (bctx # json) in

    if bound then begin

      let form   = Joy.create ~template:(bound_form back) ~source ~i18n:(ctx # i18n) in

      match Joy.result form with
	| Bad errors ->
	  
	  let json = Joy.response (Joy.set_errors errors form) in
	  return $ O.Action.json json response
	    
	| Ok result ->
	  	  
	  let! id   = ohm $ MRelatedInstance.update_bound
	    rid
	    ~access:(result # access) 
	  in
	  
	  return $ O.Action.javascript (Js.redirect back) response
      
    end else begin 
      
      let form   = Joy.create ~template:(unbound_form back) ~source ~i18n:(ctx # i18n) in

      match Joy.result form with
	| Bad errors ->
	  
	  let json = Joy.response (Joy.set_errors errors form) in
	  return $ O.Action.json json response
	    
	| Ok result ->
	  	  
	  let! id   = ohm $ MRelatedInstance.update_unbound
	    rid
	    ~name:(result # name)
	    ~site:(result # site)
	    ~access:(result # access) 
	  in
	  
	  return $ O.Action.javascript (Js.redirect back) response

    end 

  end

let box ~ctx rid data = 

  let bound = MRelatedInstance.is_bound data in 

  let! save = save ~ctx rid bound in

  O.Box.leaf begin fun bctx (prefix,_) ->

    let back = UrlR.build (ctx # instance) (bctx # segments) (prefix,`List) in

    let! desc = ohm $ MRelatedInstance.describe data in

    if MRelatedInstance.is_bound data then 

      let source = Joy.from_seed (object
	method access      = desc # access
      end) in
      
      let form = Joy.create 
	~template:(bound_form back) ~source ~i18n:(ctx # i18n)
      in
      return $ Joy.render form (bctx # reaction_url save)
	
    else

      let source = Joy.from_seed (object
  	method name        = BatOption.default "" desc # name
	method access      = desc # access
	method site        = desc # site 
      end) in
      
      let form = Joy.create 
	~template:(unbound_form back) ~source ~i18n:(ctx # i18n) 
      in
      return $ Joy.render form (bctx # reaction_url save)
	      
  end
