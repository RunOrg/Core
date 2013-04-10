(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let none = return None

let actor cuid iid = 
  let! actor = ohm_req_or none $ MAvatar.identify iid cuid in
  return $ MActor.member actor 

let item_url cuid itid = 
  let! iid     = ohm_req_or none $ MItem.iid itid in
  let! actor   = ohm_req_or none $ actor cuid iid in
  let! item    = ohm_req_or none $ MItem.try_get actor itid in
  let! instance = ohm_req_or none $ MInstance.get (item # iid) in 			      
  match item # where with 
    | `feed fid -> begin
      let! feed = ohm_req_or none $ MFeed.try_get actor fid in 
      match MFeed.Get.owner feed with 
	| `Event eid -> return $ Some (Action.url UrlClient.Events.see
					 (instance # key) [ IEvent.to_string eid ])
	| `Discussion did -> return $ Some (Action.url UrlClient.Discussion.see
					      (instance # key) [ IDiscussion.to_string did ])
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
			      return $ Some (Action.url UrlClient.Inbox.home (instance # key) [])

    | `EventInvite (eid,_) -> let! iid = ohm_req_or none $ MEvent.instance eid in 
			      let! instance = ohm_req_or none $ MInstance.get iid in 
			      return $ Some (Action.url UrlClient.Events.see (instance # key) 
					       [ IEvent.to_string eid ])

    | `EventRequest (eid,aid) -> let! iid = ohm_req_or none $ MEvent.instance eid in 
				 let! instance = ohm_req_or none $ MInstance.get iid in 	
				 return $ Some 
				   (Action.url UrlClient.Events.join (instance # key) [ IEvent.to_string eid ;
											IAvatar.to_string aid ])

    | `GroupRequest (gid,aid) -> let! iid = ohm_req_or none $ MGroup.instance gid in 
				 let! instance = ohm_req_or none $ MInstance.get iid in 
				 let! group = ohm_req_or none $ MGroup.get gid in 
				 return $ Some 
				   (Action.url UrlClient.Members.join (instance # key) 
				      [ IGroup.to_string gid ; IAvatar.to_string aid ])
				   
    | `CanInstall iid -> let! ins  = ohm_req_or none $ MInstance.Profile.get iid in 
			 let  owid = snd (ins # key) in
			 if ins # unbound = None then none else 
			   return $ Some (Action.url UrlNetwork.install owid iid) 

    | `NewWallItem (_,itid) 
    | `NewFavorite (_,_,itid) -> item_url cuid itid

    | `NewComment (_,cid) -> let! itid = ohm_req_or none $ MComment.item cid in 
			     item_url cuid itid


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
			      let! () = ohm $ MNews.Cache.prepare uid in
			      let! () = ohm $ MNotify.Stats.from_mail nid in 
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
		      CPageLayout.core (req # server) `Notify_Expired_Title html res	
end
