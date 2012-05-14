(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let form cancel_url = 
  Joy.begin_object (fun ~name ~owners ~request ->
    (object
      method name        = name
      method owners      = owners
      method request     = request
     end))
	
      |> Joy.append (fun f name -> f ~name) 
	  (VQuickForm.longinput
	     ~label:(`label "network.field.name")
	     ~minitip:(`label "network.field.name.tip")
	     ~required:true
	     (fun _ init -> init # name)
	     (fun _ field value -> match value with 
	       | Some string -> Ok string
	       | None -> Bad (field,`label "field.required")
	     )
	  )
	  
      |> Joy.append (fun f owners -> f ~owners) 
	  (VQuickForm.longinput
	     ~label:(`label "network.field.owners")
	     ~minitip:(`label "network.field.owners.tip")
	     ~required:true
	     (fun _ init -> String.concat " ; " (init # owners))
	     (fun _ field value -> match value with 
	       | Some string -> let strings = BatString.nsplit string ";" in
				let clean   = List.map EmailUtil.canonical strings in 
				Ok clean
	       | None -> Bad (field,`label "field.required")
	     )
	  )
	  
      |> Joy.append (fun f request -> f ~request) 
	  (VQuickForm.textarea
	     ~label:(`label "network.field.request")
	     ~tall:true
	     ~required:true
	     (fun _ init -> init # request) 
	     (fun _ field value ->  match value with 
	       | Some string -> Ok string
	       | None -> Bad (field,`label "field.required"))
	  )
	  
      |> Joy.end_object 
      |> Joy.wrap Joy.here (VNetwork.New.render (object
	method back = cancel_url
      end))

let save ~ctx = 
  O.Box.reaction "post" begin fun self bctx (prefix,_) response -> 
    
    let back   = UrlR.build (ctx # instance) (bctx # segments) (prefix,`List) in
    let source = Joy.from_post_json (bctx # json) in
    let form   = Joy.create ~template:(form back) ~source ~i18n:(ctx # i18n) in

    match Joy.result form with
      | Bad errors ->
	
	let json = Joy.response (Joy.set_errors errors form) in
	return $ O.Action.json json response
	  
      | Ok result ->
	
	let  iid  = IIsIn.instance (ctx # myself) in 
	let! self = ohm $ ctx # self in
	
	let  emails = result # owners in 

	let! owner_avatars = ohm $ Run.list_map begin fun email -> 
	  CHelper.create_avatar 
	    ~firstname:""
	    ~lastname:""
	    ~email:(Some email)
	    iid
	end emails in 
	
	let! owner_opts = ohm $ Run.list_map begin fun aid -> 
	  let! details = ohm $ MAvatar.details aid in 
	  return (details # who) 
	end owner_avatars in 

	let owners = BatList.filter_map identity owner_opts in
	
	let! id   = ohm $ MRelatedInstance.create 
	  iid self
	  ~name:(result # name)
	  ~request:(result # request) 
	  ~owners
	  ~site:None
	  ~access:`Public
	in
	
	let url = 
	  UrlR.build (ctx#instance) 
	    (bctx # segments)
	    (prefix,`Item (IRelatedInstance.decay id))
	in
	
	return $ O.Action.javascript (Js.redirect url) response

  end

let box ~ctx = 

  let! save = save ~ctx in

  O.Box.leaf begin fun bctx (prefix,_) ->

    let back = UrlR.build (ctx # instance) (bctx # segments) (prefix,`List) in

    let name = ctx # instance # name in
    let request = View.write_to_string (VNetwork.NewRequest.render name (ctx # i18n)) in

    let source = Joy.from_seed (object
      method name        = ""
      method owners      = []
      method request     = request
    end) in

    let form = Joy.create ~template:(form back) ~source ~i18n:(ctx # i18n) in

    return $ Joy.render form (bctx # reaction_url save)

  end
