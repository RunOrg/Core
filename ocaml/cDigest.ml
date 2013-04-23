(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

(* num == -1 : instance itself. Offset all + 1*)

let to_action (iid,num) = 
  IMail.Action.of_string (IInstance.to_string iid ^ "-" ^ string_of_int (1 + num))

let of_action aid = 
  let! aid = req_or None aid in 
  let  str = IMail.Action.to_string aid in
  try let  iid, num = BatString.split str "-" in 
      Some (IInstance.of_string iid, int_of_string num - 1)
  with _ -> None

let () = MDigest.Send.define begin fun uid u t info ->

  let event_url iid eid default = 
    let! access = ohm_req_or (return default) (CAccess.of_notification uid iid) in
    let! event = ohm_req_or (return default) $ MEvent.view ~actor:(access # actor) eid in
    return (Action.url UrlClient.Events.see (access # instance # key) [ IEvent.to_string eid ])
  in

  let discussion_url iid did default = 
    let! access = ohm_req_or (return default) (CAccess.of_notification uid iid) in
    let! discn = ohm_req_or (return default) $ MDiscussion.view ~actor:(access # actor) did in
    return (Action.url UrlClient.Discussion.see (access # instance # key) [ IDiscussion.to_string did ])
  in

  let render_item access (url,(owner,time,what,unread)) = 

    let! name, pic = ohm_req_or (return None) begin 
      match owner with 
      | `Event eid -> 
	let! event = ohm_req_or (return None) $ MEvent.view ~actor:(access # actor) eid in
	let! name  = ohm (MEvent.Get.fullname event) in 
	let! pic   = ohm (CPicture.small_opt (MEvent.Get.picture event)) in 
	return (Some (name,pic))
      | `Discussion did -> 
	let! discn = ohm_req_or (return None) $ MDiscussion.view ~actor:(access # actor) did in
	return (Some (MDiscussion.Get.title discn, None))
    end in 

    return (Some (object
      method name   = name
      method pic    = pic
      method url    = url 
      method unread = unread
      method what   = (what,unread) 
    end))

  in

  return (Some (object

    method item = None

    method act aid = let  default  = Action.url UrlMe.News.home (u # white) () in
		     let! iid, num = req_or (return default) (of_action aid) in 
		     let! list     = req_or (return default) 
		       (try Some (List.assoc iid (t # list)) with Not_found -> None) in

		     let! instance = ohm_req_or (return default) (MInstance.get iid) in
		     let  default  = Action.url UrlClient.Inbox.home (instance # key) [] in

		     let! owner, _, _, _ = req_or (return default) 
		       (try Some (List.nth list num) with _ -> None) in
		     
		     match owner with 
		     | `Event eid -> event_url iid eid default
		     | `Discussion did -> discussion_url iid did default 

    method mail = let! now = ohmctx (#date) in 
		  let  title = `Digest_Title (Date.ymd now) in

		  let  url instance n = 
		    CMail.link (info # id) (Some (to_action (instance # id,n))) (snd (instance # key)) in

		  let! instances = ohm (Run.list_filter begin fun (iid, items) -> 

		    let! instance = ohm_req_or (return None) (MInstance.get iid) in 
		    let! ipic     = ohm (CPicture.small_opt (instance # pic)) in 
		    
		    let! access = ohm_req_or (return None) (CAccess.of_notification uid iid) in

		    let  items = BatList.mapi (fun i item -> url instance i, item) items in
		    let! items = ohm (Run.list_filter (render_item access) items) in 

		    if items = [] then return None else return (Some (object
		      method url   = url instance (-1) 
		      method name  = instance # name 
		      method pic   = ipic
		      method items = items 
		    end))

		  end (t # list)) in

		  let  payload = `Digest instances in 
		  let  body = [[ `Digest_Body ]] in
		  let  buttons = [] in

		  return (title, payload, body, buttons) 

  end))
end
