(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module Sidebar = CInstance_sidebar
module Start   = CInstance_start
module Profile = CInstance_profile

let () = CClient.register UrlClient.cancel begin fun i18n (iid, instance) request response ->
  return (Action.html identity response)
end

(* Root box + home box -------------------------------------------------------------------- *)

module Boxes = struct

  open Ohm

  let home_wall ~wall ~(ctx:'any CContext.full) = 
    O.Box.decide begin fun input (prefix,_) -> 
      
      let! wall = ohm wall in

      let config = object
	method react  = true
	method chat a = Some (UrlChat.instance (ctx # instance) a)
      end in
      
      return $ CWall.full_nested_box ~ctx ~wall ~config
	
    end
    
  let start_box ~ctx = 
    O.Box.leaf begin fun input _ ->
      let! vert = ohm $ MVertical.get_cached (ctx # instance # ver) in
      return $ VStart.Asso.render (object
	method hints = Start.hints ctx
	method steps = List.filter MStart.numbered_step vert # steps 
      end) (ctx # i18n)
    end

  let home ~(ctx:[`Unknown] CContext.full) = 

    let wall = Run.memo (MFeed.get_for_instance ctx) in

    let only_admin what = 
      match CClient.is_admin (ctx # myself) with 
	| None      -> return None
	| Some isin -> let ctx = CContext.evolve_full isin ctx in
		       return $ Some (what ~ctx)
    in

    let only_token what = 
      match CClient.is_token (ctx # myself) with 
	| None      -> return None
	| Some isin -> let ctx = CContext.evolve_full isin ctx in
		       return $ Some (what ~ctx)
    in

    let only_contact what = 
      match CClient.is_contact (ctx # myself) with 
	| None      -> return None
	| Some isin -> let ctx = CContext.evolve_full isin ctx in
		       return $ Some (what ~ctx)
    in

    let onlyif cond what = if cond then return $ Some (what ~ctx) else return None in
    let onlyif_req cond what =
      if cond then 
	let! box = ohm $ what ~ctx in
	return $ Some box
      else 
	return None
    in

    let only_if_contact what = 
      match CClient.is_token (ctx # myself) with 
	| None      -> return $ Some what 
	| Some isin -> return None
    in

    let chat = 
      let! wall = ohm wall in
      let! wall = ohm_req_or (return None) $ MFeed.Can.read wall in
      return $ Some (CChat.box ~ctx ~wall) 
    in

    let directory = 
      let! iid = ohm_req_or (return None) $
	MInstanceAccess.can_view_directory ctx
      in
      return $ Some (CDirectory.home_box ~iid ~ctx) 
    in

    let contacts ~ctx = 
      let iid = IIsIn.instance (ctx # myself) in
      CContacts.home_box ~iid ~ctx
    in

    let missing =
      if ctx # instance # stub then Profile.box ~ctx else 
	O.Box.leaf begin fun input (prefix,_) -> 	 
	  let is_only_client = None = CClient.is_token (ctx # myself) in
	  if is_only_client then 
	    let url = UrlSubscription.start # build (ctx # instance) in
	    return $ VSubscription.Forbidden.render url (ctx # i18n)
	  else
	    return $ VForbidden.render (ctx # i18n)
	end
    in
    
    O.Box.decide begin fun _ _ -> 

      let not_ag = not (CContext.is_ag ctx) in

      let not_in_ag f x = if not_ag then f x else return None in

      let! tabs = ohm begin    
	Run.list_filter begin fun (key,eval) ->
	  let! evaled = ohm eval in
	  match evaled with 
	    | Some box -> return $ Some (key,box)
	    | None     -> return None
	end [
	  `Join          , only_if_contact missing ;
	  `Feed          , not_in_ag only_token CFeed.home_box ; 
	  `Wall          , not_in_ag only_token (home_wall ~wall) ;
	  `Chat          , chat ;
	  `Start         , only_admin start_box ;
	  `Network       , onlyif true CNetwork.box ;
	  `Profile       , onlyif true Profile.box ;
	  `Asso          , only_admin CAssoOptions.home_box ;
	  `Client        , not_in_ag only_admin CAssoClient.home_box ;
	  `Admins        , only_admin CDirectory.admins_box ;
	  `Calendar      , onlyif not_ag (CEntity.Home.calendar_box) ;
	  `Courses       , onlyif not_ag (CEntity.Home.home_box `Course) ;
	  `Groups        , onlyif true (CEntity.Home.home_box `Group) ;
	  `Subscriptions , onlyif not_ag (CEntity.Home.home_box `Subscription) ;
	  `Events        , onlyif true (CEntity.Home.home_box `Event) ;
	  `Forums        , onlyif not_ag (CEntity.Home.home_box `Forum) ;
	  `Polls         , onlyif not_ag (CEntity.Home.home_box `Poll) ;
	  `Albums        , onlyif not_ag (CEntity.Home.home_box `Album) ;
	  `Grants        , onlyif not_ag (CEntity.Home.grants_box) ;
	  `Accounting    , not_in_ag only_admin CAccounting.instance_home ;
	  `Options       , only_contact CMyOptions.home_box ;
	  `Directory     , directory ;
	  `Contacts      , not_in_ag only_admin contacts ;
	  `DashMembers   , onlyif_req not_ag (CDashboard.home_box `DashMembers) ;
	  `DashActivities, onlyif_req not_ag (CDashboard.home_box `DashActivities) ;
	]
      end in
      
      return (Sidebar.tabs ctx missing tabs) 
    
    end  

  let main ~(ctx:[`Unknown] CContext.full)  = 
    O.Box.decide begin fun _ -> 
      begin 
	 function 
	   | _, `Home       -> home                  ~ctx
	   | _, `Entity     -> CEntity.View.root_box ~ctx
	   | _, `Messages   -> CMessage.home_box     ~ctx
	   | _, `Message    -> CMessage.message_box  ~ctx 
	   | _, `Profile    -> CProfile.box          ~ctx 
	   | _, `AddMembers -> CAdd.box              ~ctx 
      end |- return
    end
    |> O.Box.parse CSegs.root_pages

end

let () = CClient.User.register CClient.is_anyone UrlR.r_ajax
  begin fun ctx request response ->
    
    match request # post "same" with 

      | None -> 

	O.Box.on_reaction
	  (Boxes.main ~ctx)
	  (UrlR.builder (ctx # instance)) 
	  (request :> O.Box.source)
	  response

      | Some string -> 

	let same = 
	  try 
	    let json = Json_io.json_of_string string in
	    let list = Json_type.Browse.list Json_type.Browse.int json in
	    List.sort compare list
	  with _ -> []
	in

	O.Box.on_update
	  (Boxes.main ~ctx)
	  (UrlR.builder (ctx # instance)) 
	  (request :> O.Box.source)
	  same response

  end
    
(* Private root ----------------------------------------------------------------------------- *)

let () = CClient.register UrlClient.all begin fun i18n (iid, instance) request response ->
  return (Action.redirect (UrlR.r # build instance) response)
end

let () = CClient.User.register CClient.is_anyone UrlR.r 
  begin fun ctx request response ->

    let i18n = ctx # i18n in

    let missing = CCore.redirect_fail (UrlLogin.index # build) response in
    
    let iid  = IInstance.decay (IIsIn.instance (ctx # myself)) in
    let cuid = IIsIn.user (ctx # myself) in

    let! user_opt = ohm (MUser.get (IUser.Deduce.unsafe_can_view cuid)) in
    let! user = req_or missing user_opt in
    
    let not_contact = None <> IIsIn.Deduce.is_token (ctx # myself) in

    let title = return (View.esc (ctx # instance # name)) in
    let theme = match BatOption.map MWhite.theme (ctx # white) with 
      | None   -> BatOption.map (fun theme -> theme, `RunOrg) ctx # instance # theme 
      | Some t -> Some (t, `White) 
    in
    let light = not_contact && ctx # instance # light in 
    let trial = not_contact && ctx # instance # trial in 
    let body  =
      if ctx # instance # install then
	return (VInstance.Install.render () i18n)
      else 
	let white = ctx # white <> None in 
	return (VInstance.r ~white ~light ~trial ~iid ~i18n)
    in 

    let user_name = user # fullname in 

    let! news_count = ohm (MNotification.count cuid) in
    let! message_count = ohm (MMessage.total_count begin
      IUser.Deduce.unsafe_is_anyone cuid
      |> IUser.Assert.is_self
    end) in

    let js_files = ["/public/js/jquery-address.min.js"] in
    let js       = 
      if ctx # instance # install then 
	Js.refreshDelayed
      else	
	JsCode.seq [
	  JsBase.init (UrlR.home # build (ctx # instance)) ;
	  Js.init
	]
    in

    let runorg_name = 
      match ctx # white with 
	| None -> "RUN<strong>ORG</strong>"
	| Some white -> MWhite.name white
    in
 
    let navbar = 
      CCore.navbar runorg_name cuid user_name 
	(Some (IInstance.decay (IIsIn.instance (ctx # myself)))) news_count message_count i18n 
    in
    
    let! start = ohm begin 
      if ctx # instance # install then return None else Start.get ctx 
    end in 
        
    CCore.render ?theme ?start ~css:CCore.css_client ~navbar ~js_files ~js ~title ~body response

  end



