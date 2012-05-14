(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* Re-send e-mail for confirmation *)

let mail_i18n = MModel.I18n.load (Id.of_string "i18n-common-fr") `Fr
      
let send_confirm_mail_task = 
  Task.register "notification.confirm" INotification.fmt begin fun nid _ ->       

    let bot_nid = INotification.Assert.bot nid in 
    
    let! notification = ohm_req_or (return $ Task.Finished nid) $
      MNotification.bot_get bot_nid 
    in

    let uid = notification # who in 
    let read_nid = INotification.Assert.can_read nid (* Can be read by owner *) in

    let! success = ohm $ MMail.send_to_self uid 
      begin fun uid user send ->

	let url = 
	  (UrlCore.notify ()) # build 
	    (IUser.Deduce.self_can_login uid) 
	    read_nid
	in

	VMail.Notify.Reconfirm.send send mail_i18n
	  (object
	    method fullname = user # fullname
	    method url      = url
	   end)
      end
    in
    
    return (if success then Task.Finished nid else Task.Failed)
  end 

(* Notification endpoint : redirect or request account confirm *)

let redirect i18n user (notify : MNotification.t) fail response = 

  let fail = return fail in 

  let! iid = req_or fail (notify # inst) in
  let! instance = ohm_req_or fail (MInstance.get iid) in

  let! url = ohm_req_or fail begin match notify # chan with       

    | `myMembership 
    | `welcome      ->
      return $ Some (UrlR.home # build instance)

    | `chatReq where -> begin
      match where with 
	| `instance _   -> return $ Some (UrlR.chat # build instance)
	| `entity   eid -> return $ Some (UrlEntity.chat instance eid)
    end

    | `networkInvite rid -> 
      let url = UrlMe.build 
	Box.Seg.(UrlSegs.(root ++ me_pages ++ me_network_tabs `Requests ++ related_instance_id))
	((((),`Network),`Requests),Some rid)
      in
      return $ Some url 

    | `networkConnect rid -> 
      let! iid = ohm_req_or (return None) $ MRelatedInstance.get_follower rid in 
      let! instance = ohm_req_or (return None) $ MInstance.get iid in 
      return $ Some (UrlR.home # build instance)
	
    | `likeItem    item 
    | `publishItem item
    | `commentItem item ->
      let! ctx = ohm (CContext.full_of_user user iid instance i18n) in
      CItem.url ctx item
	
    | `joinEntity (eid, _) ->
      let (++) = Box.Seg.(++) in
      let url = 
	UrlR.build instance 
	  (Box.Seg.root ++ CSegs.root_pages ++ CSegs.entity_id) 
	  (((),`Entity),Some eid)
      in
      return $ Some url
	
    | `joinPending eid ->	
      let url = 
	UrlR.build instance 
	  Box.Seg.(CSegs.(root ++ root_pages ++ entity_id ++ entity_tabs))
	  ((((),`Entity),Some eid),`Admin_People)
      in
      return $ Some url
	
  end in 
 
  let login  = IUser.Deduce.self_can_login user in 

  let! _ = ohm $ MNews.FromLogin.create 
    (`Notification (iid, MNotification.type_of_channel (notify # chan), IUser.decay user)) 
  in
  
  return (CSession.with_login_cookie login false (response url))

let require_confirm i18n user data notify fail response = 

  let title = `label "notify.confirm" in
  let! ins = ohm $ Run.opt_bind MInstance.get (notify # inst) in
    
  let inviter, image = match ins with 
    | None -> I18n.translate i18n (`label "anonymous"), None
    | Some ins -> ins # name, ins # pic
  in
    
  let! image = ohm $ CPicture.large image in

  let! white = ohm $ Run.opt_bind MWhite.get (BatOption.bind (#white) ins) in

  let runorg_name = 
    match white with 
      | None -> "RUN<strong>ORG</strong>"
      | Some white -> MWhite.name white
  in

  let body = 
    return (
      VLogin.Confirm.render 
	(object
	  method title      = title
	  method name       = runorg_name
	  method init       = FConfirm.Form.empty
	  method url        = UrlCore.setpass # build (IUser.Deduce.self_can_login user)
	  method login_init = FLogin.Form.empty
	  method login_url  = UrlLogin.merge # build (IUser.Deduce.self_can_login user)
	  method email      = data # email
	  method fullname   = data # fullname
	  method image      = image
	  method inviter    = inviter
	  method fb_url     = UrlLogin.fb_confirm # build (IUser.Deduce.self_can_confirm user)
	  method fb_channel = UrlLogin.fb_channel # build
	  method fb_app_id  = MModel.Facebook.config # app_id
	 end)
	i18n
      |- View.Context.add_js_code (Js.setTrigger FConfirm.trigger Js.refresh) 	  
    )
  in

  let theme = match BatOption.map MWhite.theme white with 
    | None   -> BatOption.map (fun theme -> theme, `RunOrg) (BatOption.bind (#theme) ins)
    | Some t -> Some (t, `White) 
  in
      
  CCore.render ?theme ~title:(return (I18n.get i18n title)) ~body response

let require_resend i18n (nid:INotification.t) response = 

  let! _ = ohm $ MModel.Task.call send_confirm_mail_task nid in   

  let! iid   = ohm $ MNotification.instance nid in
  let! ins   = ohm $ Run.opt_bind MInstance.get iid in 
  let! white = ohm $ Run.opt_bind MWhite.get (BatOption.bind (#white) ins) in

  let runorg_name = 
    match white with 
      | None -> "RUN<strong>ORG</strong>"
      | Some white -> MWhite.name white
  in

  let title = return $ I18n.get i18n (`label "notify.confirm") in
  let body  = return $ VLogin.Resend.render runorg_name i18n in

  let theme = match BatOption.map MWhite.theme white with 
    | None   -> BatOption.map (fun theme -> theme, `RunOrg) (BatOption.bind (#theme) ins)
    | Some t -> Some (t, `White) 
  in
      
  CCore.render ?theme ~title ~body response

let () = CCore.register (UrlCore.notify ()) begin fun i18n request response ->

  let generic_fail = 
    let url  = 
      UrlMe.build 
	Box.Seg.(root ++ CSegs.me_pages ++ CSegs.me_news_tabs `Notifications) 
	(((),`News),`Notifications) 
    in
    Action.redirect url response
  in

  let! id    = req_or (return generic_fail) (request # args 0) in
  let! proof = req_or (return generic_fail) (request # args 1) in

  let nid = INotification.of_string id in 

  let user = BatOption.bind CSession.get_login_cookie (request # cookie CSession.name) in

  let! result = ohm $ MNotification.from_link proof user nid in

  match result with 
    | `missing -> return generic_fail
    | `connected (user, notify) ->
	
      let user = 
	(* We are on the core action: it's safe *)
	ICurrentUser.Assert.is_safe user |> IUser.Deduce.is_self 
      in
	
      let! data = ohm_req_or (return generic_fail) $ 
	MUser.get (IUser.Deduce.self_can_view user)
      in
        
      if data # confirmed then 
	redirect i18n user notify generic_fail (fun url -> Action.redirect url response) 
      else
	require_confirm i18n user data notify generic_fail response     
	
    | `not_connected notify ->

      let! confirmed = ohm $ MUser.confirmed (notify # who) in 

      if confirmed then 
	return generic_fail 
      else 
	require_resend i18n nid response

end
    
(* Display notifications ------------------------------------------------------------------- *)

let sender_info i18n =
  let details = memoize MAvatar.details in
  let picture = memoize CPicture.small in
    fun from ->
      let! avatar = ohm $ details from in 
      let! pic    = ohm $ picture (avatar # picture) in
      let  name   = CName.get i18n avatar in
      return (name, pic)

type notification_context = <
  instance : MInstance.t ;
  iid      : IInstance.t ;
  notify   : MNotification.t ;
  user     : [`IsSelf] IUser.id ;
  i18n     : I18n.t ;
  sender   : IAvatar.t -> (string * string) O.run ;
  isin     : [`Unknown] IIsIn.id	     
> ;;

module MyMembership = struct

  let render ~nctx =
    Run.list_collect begin function
      |`myMembership m -> 
	
	let! from, picture = ohm $ nctx # sender (m # who) in
	
	let render = match m # what with 
	  | `toAdmin  -> VNotification.Item.become_admin
	  | `toMember -> VNotification.Item.become_member 
	in
	
	return [ render ~from ~picture ]
	  
      | _ -> return []
    end nctx # notify # what 
	
end

module LikeItem = struct

  let render item ~nctx = 
    let ctx = CContext.make (nctx # isin) in 
    let self_opt = ctx # self_if_exists in	
    
    let first, count = List.fold_left begin fun (first, count) item ->
      match item with 
	| `likeItem i -> (if first = None then Some (i # who) else first) , count + 1
	| _           -> first, count
    end (None, 0) (nctx # notify # what) in

    let! item   = ohm_req_or (return []) $ MItem.try_get ctx item in
    let! sender = req_or (return []) first in

    let! from, picture = ohm $ nctx # sender sender in
	  
    let! author = req_or (return []) $ MItem.author (item # payload) in 

    let! render = ohm begin  
      if Some author = BatOption.map IAvatar.decay self_opt then 
	return (VNotification.Item.like_your_item)
      else if author = sender then 
	return (VNotification.Item.like_their_item)
      else 
	let! author, _ = ohm $ nctx # sender author in
	return $ VNotification.Item.like_item ~author	
    end in
    
    return [render ~from ~picture]
	
end

module CommentItem = struct

  let render item ~nctx = 
    let ctx = CContext.make (nctx # isin) in
    let self_opt = ctx # self_if_exists in	      

    let first, count = List.fold_left begin fun (first, count) item ->
      match item with 
	| `commentItem i -> (if first = None then Some (i # who) else first) , count + 1
	| _              -> first, count
    end (None, 0) (nctx # notify # what) in
    
    let! item   = ohm_req_or (return []) $ MItem.try_get ctx item in
    let! sender = req_or (return []) first in 

    let! from, picture = ohm $ nctx # sender sender in
    
    let! author = req_or (return []) $ MItem.author (item # payload) in 

    let! render = ohm begin
      if Some author = BatOption.map IAvatar.decay self_opt then 
	return VNotification.Item.comment_your_item 
      else if author = sender then 
	return VNotification.Item.comment_their_item 
      else
	let! author, _ = ohm $ nctx # sender author in
	return $ VNotification.Item.comment_item ~author	
    end in
    
    return [render ~from ~picture]
	  
end

module NetworkInvite = struct

  let render ~nctx =
    Run.list_collect begin function
	| `networkInvite m -> 
	  let! from, picture = ohm $ nctx # sender (m # who) in	  
	  return [ VNotification.Item.network_invite ~from ~picture ]
	| _ -> return []
      end nctx # notify # what 

end 

module NetworkConnect = struct

  let render ~nctx =
    Run.list_collect begin function
	| `networkConnect m ->
	  let  rid = m # contact in
	  let! iid = ohm_req_or (return []) $ MRelatedInstance.get_follower rid in 
	  let! instance = ohm_req_or (return []) $ MInstance.get iid in
	  let  from = instance # name in
	  let! picture = ohm $ CPicture.small (instance # pic) in
	  return [ VNotification.Item.network_connect ~from ~picture ]
	| _ -> return []
      end nctx # notify # what 

end 

module PublishItem = struct

  let render item ~nctx = 
    
    let ctx = CContext.make (nctx # isin) in
    
    let first, count = List.fold_left begin fun (first, count) item ->
      match item with 
	| `publishItem i -> (if first = None then Some (i # who) else first) , count + 1
	| _              -> first, count
    end (None, 0) (nctx # notify # what) in
    
    let! item = ohm_req_or (return []) (MItem.try_get ctx item) in
    let! first = req_or (return []) first in
    
    let! (from,picture) = ohm (nctx # sender first) in
    
    return [VNotification.Item.publish_item ~from ~picture]
      
end

module ChatRequest = struct

  let render r ~nctx = 

    let ctx = CContext.make (nctx # isin) in

    Run.list_collect begin function
      | `chatReq r ->
 
	let! entity_name = ohm begin match r # where with 
	  | `instance _ -> return None
	  | `entity eid -> let! entity = ohm_req_or (return None) (MEntity.try_get ctx eid) in
			   let! entity = ohm_req_or (return None) (MEntity.Can.view entity) in
			   return $ Some (CName.of_entity entity)
	end in 
	
	let where = BatOption.default (`text (nctx # instance # name)) entity_name in
	let! from, picture = ohm (nctx # sender (r # who)) in
	let topic = r # topic in
	
	return [VNotification.Item.chat_request ~from ~picture ~where ~topic]
	  
      | _ -> return []
    end nctx # notify # what 
      
end

module Welcome = struct

  let render ~nctx = return []

end

module JoinEntity = struct

  let render eid ~nctx =

    Run.list_collect begin function 
	| `joinEntity j ->  
	  
	  let! from, picture = ohm $ nctx # sender (j # who) in 

	  let render = match j # how, j # kind with
	    | `invite, `Subscription -> VNotification.Item.invite_subscription
	    | `invite, `Event        -> VNotification.Item.invite_event
	    | `invite, `Group        -> VNotification.Item.invite_group
	    | `invite, `Album        -> VNotification.Item.invite_album
	    | `invite, `Course       -> VNotification.Item.invite_course
	    | `invite, `Poll         -> VNotification.Item.invite_poll
	    | `invite, `Forum        -> VNotification.Item.invite_forum
	  in
	    
	  return [ render ~from ~picture ]	  
	    
	| _ -> return []

    end nctx # notify # what
	              
end

module JoinPending = struct

  let render eid ~nctx =

    let ctx = CContext.make (nctx # isin) in
    
    let! entity_opt = ohm (MEntity.try_get ctx eid) in
    let! entity = req_or (return []) entity_opt in
    let! managed_opt = ohm (MEntity.Can.admin entity) in
    let! managed = req_or (return []) managed_opt in

    let entity = CName.of_entity managed in 

    Run.list_collect begin function 
	| `joinPending j ->  
	  
	  let! (from,picture) = ohm (nctx # sender (j # who)) in
	  return [ VNotification.Item.join_pending ~entity ~from ~picture ]
		    
	| _ -> return []

    end nctx # notify # what 
	              
end

(* Notification list box ------------------------------------------------------------------ *)

let box ~user ~i18n =
  let cuser = user in 
  O.Box.leaf 
    begin fun input _ -> 

      let user = IUser.Deduce.is_self cuser in
      let sender_info = sender_info i18n in

      let identify = 
	memoize
	  (fun iid -> MAvatar.identify iid (IUser.Deduce.self_is_unsafe user) |> Run.memo)
      in

      let render_item (isnew, id, notify) = 
	
	let! iid = req_or (return []) (notify # inst) in
	let! instance = ohm_req_or (return []) $ MInstance.get iid in
	
	let url = (UrlCore.notify ()) # build (IUser.Deduce.self_can_login user) id in 
	
	let! isin = ohm $ identify iid in
	
	let nctx : notification_context = object
	  method sender   = sender_info
	  method notify   = notify
	  method iid      = iid
	  method instance = instance
	  method isin     = isin 
	  method i18n     = i18n
	  method user     = user
	end in
	  
	let! renderables = ohm begin match notify # chan with 
	  | `networkInvite  _  -> NetworkInvite.render    ~nctx
	  | `myMembership      -> MyMembership.render     ~nctx 
	  | `publishItem    i  -> PublishItem.render    i ~nctx
	  | `likeItem       i  -> LikeItem.render       i ~nctx
	  | `commentItem    i  -> CommentItem.render    i ~nctx 
	  | `welcome           -> Welcome.render          ~nctx 
	  | `joinEntity  (j,_) -> JoinEntity.render     j ~nctx 
	  | `joinPending    j  -> JoinPending.render    j ~nctx
	  | `networkConnect _  -> NetworkConnect.render   ~nctx 
	  | `chatReq        r  -> ChatRequest.render    r ~nctx
	end in
	
	let render renderable = 
	  ( renderable ~instance:(instance # name) ~url ~time:(notify # time) ~isnew
	      : VNotification.Item.item_content )
	in
	
	return $ List.map render renderables
	  
      in
      
      let! items = ohm $ MNotification.fetch user 10 in 
      let! content = ohm $ Run.list_collect render_item items in 

      return $ VNotification.full 
	~content
	~i18n
    end

(* CNotification ping --------------------------------------------------------------------- *)

let () = CCore.User.register_ajax UrlCore.ping begin fun i18n user request response ->      
  let! news_count = ohm $ MNotification.count user in
  let! message_count = ohm $ MMessage.total_count (IUser.Deduce.is_self user) in
  return $ Action.javascript (JsCode.seq [
    Js.notify ~id:`news    ~unread:(news_count # unread) ~total:(news_count # total) ;
    Js.notify ~id:`message ~unread:(message_count)       ~total:(message_count) ;
  ]) response

end

let () = CClient.User.register CClient.is_contact UrlClient.ping 
  begin fun ctx request response ->    

    let uid  = IIsIn.user (ctx # myself) in
    let self = 
      IUser.Deduce.unsafe_is_anyone uid |> IUser.Assert.is_self
    in 

    let! news_count    = ohm $ MNotification.count uid in
    let! message_count = ohm $ MMessage.total_count self in
    
    (* If admin _and_ there's an active step right now, try and refresh it. *)

    let! step = ohm begin

      let! admin   = req_or (return None) $ IIsIn.Deduce.is_admin (ctx # myself) in 
      let  iid     = IIsIn.instance admin in 

      let! current = req_or (return None) $ BatOption.bind
	(Json_type.Build.string |- MStart.Step.of_json_safe)
	(request # post "start")
      in
      let! state   = ohm $ MStart.get ~force:true iid in 

      let! vert  = ohm $ MVertical.get_cached (ctx # instance # ver) in
      let  steps = vert # steps in

      let real_current = MStart.next_step state steps in 
      if Some current = real_current then return None else 
	match real_current with None -> return (Some None) | Some step -> 
	  let  nth  = MStart.step_number step steps in 
	  let! view = ohm $ CStart.get_next_step nth ctx step in
	  return $ Some (Some view)
	      
    end in  

    let code = BatList.filter_map identity [
      Some (Js.notify ~id:`news    ~unread:(news_count # unread) ~total:(news_count # total)) ;
      Some (Js.notify ~id:`message ~unread:(message_count)       ~total:(message_count)) ;
      BatOption.map Js.Start.refresh step 
    ] in

    return $ Action.javascript (JsCode.seq code) response
      
  end

(* Whether an user has unread notifications ----------------------------------------------- *)

let has_unread uid = 
  let! news_count = ohm $ MNotification.count uid in
  return (news_count # unread > 0)
