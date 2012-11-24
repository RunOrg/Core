(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let none = return None

let access cuid iid = 
  let! isin = ohm $ MAvatar.identify iid cuid in
  let! isin = req_or none $ IIsIn.Deduce.is_token isin in
  let! self = ohm $ MAvatar.get isin in 
  return $ Some (object
    method self = self
    method isin = isin
   end)

let item_url cuid itid = 
  let! iid     = ohm_req_or none $ MItem.iid itid in
  let! access  = ohm_req_or none $ access cuid iid in
  let! item    = ohm_req_or none $ MItem.try_get access itid in
  let! instance = ohm_req_or none $ MInstance.get (item # iid) in 			      
  match item # where with 
    | `feed fid -> begin
      let! feed = ohm_req_or none $ MFeed.try_get access fid in 
      match MFeed.Get.owner feed with 
	| `of_instance _ -> return $ Some (Action.url UrlClient.Home.home (instance # key) [])
	| `of_entity eid -> begin 
	  let! entity = ohm_req_or none $ MEntity.try_get access eid in 
	  return $ Some (Action.url 
	    (if MEntity.Get.kind entity = `Event then UrlClient.Events.see
	     else UrlClient.Forums.see) 
	    (instance # key) [ IEntity.to_string eid ])
	end 
	| `of_message  _ -> return None
    end
    | `album  aid -> return None
    | `folder fid -> return None		
		 
let url cuid (notify:MNotify.Store.t) =
  (* We're looking for an URL, so it's safe to act as a confirmed user *)
  let cuid = ICurrentUser.Assert.is_old cuid in  
  match notify # payload with 

    | `NewUser _ -> return None

    | `NewJoin (_,aid) -> let! p = ohm $ CAvatar.mini_profile aid in
			  return $ Some (p # url) 

    | `NewInstance (iid,_) -> let! instance = ohm_req_or none $ MInstance.get iid in 
			      return $ Some (Action.url UrlClient.website (instance # key) ())

    | `BecomeMember (iid,_)
    | `BecomeAdmin (iid,_) -> let! instance = ohm_req_or none $ MInstance.get iid in 
			      return $ Some (Action.url UrlClient.Home.home (instance # key) [])

    | `EntityInvite (eid,_) -> let! iid = ohm_req_or none $ MEntity.instance eid in 
			       let! instance = ohm_req_or none $ MInstance.get iid in 
			       return $ Some (Action.url UrlClient.Events.see (instance # key) 
						[ IEntity.to_string eid ])
    | `EntityRequest (eid,aid) -> let! iid = ohm_req_or none $ MEntity.instance eid in 
				  let! instance = ohm_req_or none $ MInstance.get iid in 
				  let! entity = ohm_req_or none $ MEntity.naked_get eid in 
				  let  res url = return $ Some 
				    (Action.url url (instance # key) [ IEntity.to_string eid ;
								       IAvatar.to_string aid ])
				  in
				  res (match MEntity.Get.kind entity with 
				    | `Forum -> UrlClient.Forums.join
				    | `Event -> UrlClient.Events.join
				    | _      -> UrlClient.Members.join)

    | `CanInstall iid -> let! ins  = ohm_req_or none $ MInstance.Profile.get iid in 
			 let  owid = snd (ins # key) in
			 if ins # unbound = None then none else 
			   return $ Some (Action.url UrlNetwork.install owid iid) 

    | `NewWallItem (_,itid) 
    | `NewFavorite (_,_,itid) -> item_url cuid itid

    | `NewComment (_,cid) -> let! itid = ohm_req_or none $ MComment.item cid in 
			     item_url cuid itid


module ResendArgs = Fmt.Make(struct
  type json t = <
    nid : INotify.t ;
    uid : IUser.t 
  >
end)

let resend_notification = 
  let task = O.async # define "resend-notify" ResendArgs.fmt 
    begin fun arg -> 

      let! _ = ohm $ MMail.other_send_to_self (arg # uid) 
	begin fun self user send -> 

	  let  token = MNotify.get_token (arg # nid) in 
	  let  url = Action.url UrlMe.Notify.mailed (user # white) (arg # nid,token) in
	  
	  let  body = Asset_Mail_NotifyResend.render (object
	    method url   = url 
	    method name  = user # fullname
	  end) in
	  
	  let! from, html = ohm $ CMail.Wrap.render (user # white) self body in
	  let  subject = AdLib.get `Mail_NotifyResend_Title in
 
	  send ~owid:(user # white) ~from ~subject ~html

	end in

      return () 

    end in
  fun ~nid ~uid -> task (object
    method nid = nid
    method uid = uid
  end)


let () = UrlMe.Notify.def_mailed begin fun req res -> 

  let nid, proof = req # args in
  let cuid = match CSession.check req with 
    | `None     -> None
    | `New _    -> None
    | `Old cuid -> Some cuid 
  in

  let! what = ohm $ MNotify.from_token nid proof cuid in 
  
  let home = Action.url UrlMe.Notify.home (req # server) () in

  match what with 
    | `Valid (notify,cuid) -> let uid = IUser.Deduce.is_anyone cuid in 
			      let! () = ohm $ MAdminLog.log 
				~uid
				(MAdminLog.Payload.LoginWithNotify 
				   (MNotify.Payload.channel notify # payload))
			      in
			      let! () = ohm $ MNews.Cache.prepare uid in
			      let! () = ohm $ MNotify.Stats.from_site nid in 
			      let! url = ohm (url cuid notify) in 
			      let  url = BatOption.default home url in
			      let! () = ohm $ TrackLog.(log (IsUser uid)) in 
			      return $ CSession.start (`Old cuid) (Action.redirect url res)
    | `Missing -> return (Action.redirect home res)
    | `Expired uid -> let title = AdLib.get `Notify_Expired_Title in
		      let html = Asset_Notify_Expired.render (object
			method navbar = (req # server,None,None)
			method title  = title 
		      end) in
		      let! () = ohm $ MNews.Cache.prepare uid in
		      let! () = ohm $ resend_notification ~nid ~uid in 
		      CPageLayout.core (req # server) `Notify_Expired_Title html res	
end
