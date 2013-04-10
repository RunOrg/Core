(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Settings = CMe_notify_settings

let  count = 10

let () = define UrlMe.Notify.def_home begin fun owid cuid ->   

  let! gender = ohm begin
    let! user = ohm_req_or (return None) $ MUser.get (IUser.Deduce.can_view cuid) in
    return (user # gender) 
  end in 

  (* Rendering a single item *)

  let! now = ohmctx (#time) in

  let render_item (who, (what:MNotify.Store.t)) = 

    let! pic, name = ohm begin 
      match who with 
	| `RunOrg _ -> begin
	  match what # payload with 
	    | `NewUser uid -> 
	      (* We must be a superadmin if we see this *)
	      let uid = IUser.Assert.bot uid in 
	      let! user = ohm_req_or (return (None,None)) $ MUser.get uid in 
	      let! pic  = ohm $ CPicture.small_opt (user # picture) in
	      return (pic, Some (user # fullname)) 
	    | _ -> return (None, None) 
	end
	| `Person (aid,_) 
	| `Event  (aid,_,_)
	| `Group  (aid,_,_) -> let! profile = ohm $ CAvatar.mini_profile aid in 
			       return (profile # pico, Some profile # name) 
    end in

    let! group_name = ohm begin
      match who with 
	| `RunOrg _ 
	| `Event  _ 
	| `Person _ -> return "-"
	| `Group (_,_,g) -> MGroup.Get.fullname g
    end in 

    let! event_name = ohm begin
      match who with 
	| `RunOrg _ 
	| `Group _ 
	| `Person _ -> return "-"
	| `Event (_,_,e) -> MEvent.Get.fullname e
    end in  

    let! text, more = ohm begin match what # payload with 
      | `NewInstance   _ -> return (`NewInstance1, [])
      | `NewUser       _ -> return (`NewUser1, [])
      | `NewJoin       _ -> return (`NewJoin1, [])
      | `BecomeAdmin   _ -> return (`BecomeAdmin1 gender, [])
      | `BecomeMember  _ -> return (`BecomeMember1, [])
      | `EventInvite   _ -> return (`EventInvite1, [ event_name, `EventInvite2 ])
      | `EventRequest  _ -> return (`EntityRequest1, [ event_name, `EntityRequest2 ])
      | `GroupRequest  _ -> return (`EntityRequest1, [ group_name, `EntityRequest2 ])
      | `NewFavorite   _ -> return (`NewFavorite1, [])
      | `NewComment (`ItemAuthor,_) -> return (`NewCommentSelf1, [])
      | `NewComment (`ItemFollower,cid) -> begin

	let! name = ohm begin 
	  let! itid    = ohm_req_or (return "") $ MComment.item cid in 
	  let! author  = ohm_req_or (return "") $ MItem.author (IItem.Assert.bot itid) in
	  let! details = ohm $ MAvatar.details author in 
	  return $ BatOption.default "" (details # name) 
	end in

	return (`NewCommentOther1, [ name , `NewCommentOther2 ])
      end
      | `NewWallItem  _ -> return (`NewWallItem1, [])
      | `CanInstall _ -> return (`CanInstall1, [])  
    end in

    return (object
      method pic  = pic
      method name = name
      method date = (what # time, now)
      method text = text
      method more = more  
      method seen = what # seen
      method url  = ""
    end)
  in

  (* Rendering a list *)

  let render_list more start = 

    let! list, next = ohm $ O.decay (MNotify.Store.all_mine ~count ?start cuid) in
    let! list = ohm $ O.decay (Run.list_filter begin fun t -> 
      let! author = ohm $ MNotify.Payload.author cuid (t # payload) in
      match author with 
	| Some (`RunOrg iid) -> return (Some (iid, (`RunOrg iid, t)))
	| Some (`Person (aid,iid)) -> return (Some (Some iid, (`Person (aid,iid), t)))
	| Some (`Group (aid,iid,g)) -> return (Some (Some iid, (`Group (aid,iid,g), t)))
	| Some (`Event (aid,iid,e)) -> return (Some (Some iid, (`Event (aid,iid,e), t)))
	| None -> let! () = ohm $ MNotify.Store.rotten (t # id) in
		  return None
    end list) in
    
    let by_iid = Ohm.ListAssoc.group_seq list in 
    
    let! list = ohm $ O.decay (Run.list_filter begin fun (iid,items) -> 
      
      let no_instance = 
	let! () = ohm $ Run.list_iter (snd |- (#id) |- MNotify.Store.rotten) items in
	return None
      in
      
      let! instance = ohm_req_or (return None)  begin
	match iid with 
	  | None -> return $ Some (object
	    method name = "RunOrg"
	    method url  = "http://runorg.com/"
	    method pic  = Some "/public/img/logo-50x50.png"
	  end)
	  | Some iid -> 
	    let! instance = ohm_req_or no_instance $ MInstance.get iid in
	    let! pic = ohm $ CPicture.small_opt (instance # pic) in
	    return $ Some (object
	      method name = instance # name
	      method url  = Action.url UrlClient.website (instance # key) ()
	      method pic  = pic
	    end)					      
      end in 
      
      let! items = ohm $ Run.list_map render_item items in
      
      return $ Some (object
	method instance = instance
	method items = items
      end)
    end by_iid) in

    Asset_Notify_List_Inner.render (object
      method list = list
      method more = match next with None -> None | Some time ->  
	Some (OhmBox.reaction_endpoint more time, Json.Null)
    end)

  in

  let! more = O.Box.react Fmt.Float.fmt begin fun time _ self res -> 
    let! html = ohm $ render_list self (Some time) in
    return $ Action.json [ "more", Html.to_json html ] res
  end in

  let! zap = O.Box.react Fmt.Unit.fmt begin fun _ _ _ res ->
    let! () = ohm (O.decay (MNotify.zap_unread cuid)) in
    return res
  end in
    
  O.Box.fill begin
    Asset_Notify_List.render (object
      method inner = render_list more None
      method zap = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint zap ())
      method options = Action.url UrlMe.Notify.settings owid () 
    end) 

  end 
end

let () = UrlMe.Notify.def_count begin fun req res -> 

  let respond count = 
    return $ Action.jsonp ?callback:(req # get "callback") (Json.Int count) res 
  in 

  let! cuid = req_or (respond 0) $ CSession.get req in 
  let! count = ohm $ MMail.All.unread cuid in 

  respond count

end 

