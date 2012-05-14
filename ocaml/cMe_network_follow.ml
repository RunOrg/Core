(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let action_source iid_list not_iid = 

  let! instances = ohm $ Run.list_filter begin fun iid ->
    if iid = not_iid then return None else 
      let! instance = ohm_req_or (return None) $ MInstance.get iid in
      return $ Some (iid, instance) 
  end iid_list in 

  let! actions = ohm $ Run.list_map begin fun (iid,instance) ->    
    let! pic = ohm $ CPicture.small (instance # pic) in
    return (iid, VMe.Network.FollowBind.render (object
      method name = instance # name
      method pic  = pic
    end))
  end instances in 

  return actions
 

let form user not_iid = 
  
  let! sta_iid_list = ohm begin 
    MAvatar.user_instances ~status:`Admin 
      (user |> IUser.Deduce.is_self |> IUser.Deduce.self_can_view_inst)
  end in 

  let iid_list = List.map (snd |- IInstance.decay) sta_iid_list in

  let! actions = ohm $ action_source iid_list not_iid in 

  let default = if List.length actions < 5 then List.map fst actions else [] in

  let form = 
    (VQuickForm.choice
       ~format:IInstance.fmt
       ~source:actions
       ~multiple:true
       ~required:true
       ~label:(`label "me.network.follow.bind")
       (fun _ init -> default)
       (fun _ field value -> match value with
	 | []    -> Bad (field,`label "field.required")
	 | list  -> Ok list))
  in

  return form  

let save iid i18n user = 
  O.Box.reaction "post" begin fun self bctx _ response -> 

    let! template = ohm $ form user iid in 
    let  source   = Joy.from_post_json (bctx # json) in    
    let  form     = Joy.create ~template ~source ~i18n in

    match Joy.result form with
      | Bad errors ->
	
	let json = Joy.response (Joy.set_errors errors form) in
	return $ O.Action.json json response
	  
      | Ok list ->
	
	let connect iid' = 
	  let  cuid = ICurrentUser.Deduce.is_unsafe user in  
	  let! isin = ohm $ MAvatar.identify iid' cuid in
	  let! isin = req_or (return ()) $ IIsIn.Deduce.is_admin isin in
	  let! self = ohm $ MAvatar.get isin in 
	  let  iid' = IIsIn.instance isin in   
	  MRelatedInstance.follow iid' self iid 
	in 

	let! () = ohm $ Run.list_iter connect list in 

	let fallback = 
	  let back = UrlMe.build 
	    O.Box.Seg.(root ++ UrlSegs.me_pages ++ UrlSegs.me_network_tabs `Search)
	    (((),`Network),`Search)
	  in
	  return $ O.Action.javascript (Js.redirect back) response
	in
	
	let! instance = ohm_req_or fallback $ MInstance.get iid in 
	
	let url = UrlR.build instance 
	  O.Box.Seg.(root ++ UrlSegs.root_pages ++ UrlSegs.home_pages) 
	  (((),`Home),`Network)
	in
	
	return $ O.Action.javascript (Js.redirect url) response
  end

let inner_box iid i18n user = 

  let! save = save iid i18n user in

  O.Box.leaf begin fun bctx _ -> 
    let fail = return $ VMe.Network.MissingFollow.render () i18n in 

    let! profile = ohm_req_or fail $ MInstance.Profile.get iid in
    let! pic     = ohm $ CPicture.small (profile # pic) in

    let details = object 
      method desc      = BatOption.default "" profile # desc
      method name      = profile # name
      method picture   = pic
    end in

    let! template = ohm $ form user iid in 
    let  template = Joy.wrap Joy.here (VMe.Network.Follow.render details) template in

    let form = Joy.create ~template ~source:Joy.empty ~i18n in

    return $ Joy.render form (bctx # reaction_url save) 

  end

let missing i18n = 
  O.Box.leaf begin fun _ _ -> return $ VMe.Network.MissingFollow.render () i18n end

let box i18n user = 
  O.Box.decide begin fun _ (_,iid_opt) ->
    match iid_opt with 
      | None     -> return $ missing i18n 
      | Some iid -> return $ inner_box iid i18n user
  end
  |> O.Box.parse UrlSegs.instance_id
