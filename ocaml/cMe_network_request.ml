(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module ActionFmt = Fmt.Make(struct
  type json t = 
    [`Decline
    |`Create
    |`Bind of IInstance.t]
end)

let action_source iid_list name = 

  let! instances = ohm $ Run.list_filter begin fun iid ->
    let! instance = ohm_req_or (return None) $ MInstance.get iid in
    return $ Some (iid, instance) 
  end iid_list in 

  let! actions = ohm $ Run.list_map begin fun (iid,instance) ->    
    let! pic = ohm $ CPicture.small (instance # pic) in
    return (`Bind iid, VMe.Network.RequestDetailBind.render (object
      method name = instance # name
      method pic  = pic
    end))
  end instances in 

  return (
    [ `Create , VMe.Network.RequestDetailCreate.render name ]
    @ actions
    @ [ `Decline , (fun i18n -> I18n.get i18n (`label "me.network.request.decline")) ]
  )

let form user details = 
  
  let! sta_iid_list = ohm begin 
    MAvatar.user_instances ~status:`Admin (user |> IUser.Deduce.is_self |> IUser.Deduce.self_can_view_inst)
  end in 

  let iid_list = List.map (snd |- IInstance.decay) sta_iid_list in

  let! actions = ohm $ action_source iid_list (details # contacted) in 

  let form = 
    (VQuickForm.choice
       ~format:ActionFmt.fmt
       ~source:actions
       ~multiple:false
       ~required:true
       ~label:(`label "me.network.request.choose")
       (fun _ init -> [`Create])
       (fun _ field value -> match value with 
	 | [x]  -> Ok x
	 | _    -> Bad (field,`label "field.required")))
      
    |> Joy.wrap Joy.here (VMe.Network.RequestDetail.render details)
  in

  return form 

let save rid i18n user = 
  O.Box.reaction "post" begin fun self bctx (prefix,_) response -> 

    let fail = return response in 

    let! rid, data = ohm_req_or fail $ MRelatedInstance.get_own user rid in

    let! asso = ohm_req_or fail $ MInstance.get data.MRelatedInstance.Data.related_to in 
    let! details = ohm $ MAvatar.details data.MRelatedInstance.Data.created_by in 

    let! pic = ohm $ CPicture.small (details # picture) in
    
    let! name, request, site = req_or fail begin match data.MRelatedInstance.Data.bind with 
      | `Bound _ -> None
      | `Unbound u -> Some MRelatedInstance.Unbound.( u.name, u.request, u.site ) 
    end in 

    let details = object 
      method text      = request
      method contact   = CName.get i18n details
      method asso      = asso # name
      method contacted = name
      method picture   = pic 
    end in

    let! template = ohm $ form user details in 

    let source = Joy.from_post_json (bctx # json) in
    
    let form = Joy.create ~template ~source ~i18n in
    
    match Joy.result form with
      | Bad errors ->
	
	let json = Joy.response (Joy.set_errors errors form) in
	return $ O.Action.json json response
	   
      | Ok `Decline ->
	
	let! ()  = ohm $ MRelatedInstance.decline rid user in
	let back = UrlMe.build bctx # segments (prefix,None) in
	return $ O.Action.javascript (Js.redirect back) response

      | Ok (`Bind iid) -> 

	let finish = 
	  let back = UrlMe.build bctx # segments (prefix,None) in
	  return $ O.Action.javascript (Js.redirect back) response
	in

	let  cuid = ICurrentUser.Deduce.is_unsafe user in  
	let! isin = ohm $ MAvatar.identify iid cuid in
	let! isin = req_or finish $ IIsIn.Deduce.is_admin isin in
	let  iid  = IIsIn.instance isin in   
	let! ()  = ohm $ MRelatedInstance.bind_to rid iid in
	
	finish 

      | Ok `Create -> 

	let! iid = ohm $ MInstance.create_stub 
	  ~who:(IUser.Deduce.is_self user) 
	  ~name
	  ~desc:None
	  ~site
	  ~profile:data.MRelatedInstance.Data.profile
	in

	let! _ = ohm $ MAvatar.become_admin iid (IUser.Deduce.is_self user) in

	let iid = IInstance.Deduce.is_admin iid in 

	let! ()  = ohm $ MRelatedInstance.bind_to rid iid in

	let fallback = 
	  let back = UrlMe.build bctx # segments (prefix,None) in
	  return $ O.Action.javascript (Js.redirect back) response
	in
	
	let! instance = ohm_req_or fallback $ MInstance.get iid in 
	
	let url = UrlR.build instance 
	  O.Box.Seg.(root ++ UrlSegs.root_pages ++ UrlSegs.home_pages) 
	  (((),`Home),`Asso)
	in

	return $ O.Action.javascript (Js.redirect url) response
  end

let box rid i18n user = 

  let! save = save rid i18n user in

  O.Box.leaf begin fun bctx _ -> 

    let fail = return $ VMe.Network.MissingRequest.render () i18n in 

    let! rid, data = ohm_req_or fail $ MRelatedInstance.get_own user rid in

    let! asso = ohm_req_or fail $ MInstance.get data.MRelatedInstance.Data.related_to in 
    let! details = ohm $ MAvatar.details data.MRelatedInstance.Data.created_by in 

    let! pic = ohm $ CPicture.small (details # picture) in
    
    let! name, request = req_or fail begin match data.MRelatedInstance.Data.bind with 
      | `Bound _ -> None
      | `Unbound u -> Some MRelatedInstance.Unbound.( u.name, u.request ) 
    end in 

    let details = object 
      method text      = request
      method contact   = CName.get i18n details
      method asso      = asso # name
      method contacted = name 
      method picture   = pic
    end in

    let! template = ohm $ form user details in 

    let form = Joy.create ~template ~source:Joy.empty ~i18n in

    return $ Joy.render form (bctx # reaction_url save) 

  end
  
