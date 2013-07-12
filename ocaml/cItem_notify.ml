(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let context_of_item access item = 
  let key = access # instance # key in
  match item # where with 
  | `feed fid -> begin
    let! feed = ohm_req_or (return None) $ MFeed.try_get (access # actor) fid in 
    match MFeed.Get.owner feed with 
    | `Event eid -> let! event = ohm_req_or (return None) 
		      (MEvent.view ~actor:(access # actor) eid) in 
		    let  url = 
		      Action.url UrlClient.Events.see key [ IEvent.to_string eid ] in
		    let! context = ohm (match MEvent.Get.name event with 
		      | None -> AdLib.get `Event_Unnamed
		      | Some name -> return name) in
		    return $ Some (url, context)
    | `Discussion did -> let! dscn = ohm_req_or (return None) 
			   (MDiscussion.view ~actor:(access # actor) did) in
			 let  url = 
			   Action.url UrlClient.Discussion.see key [ IDiscussion.to_string did ] in
			 let  context = MDiscussion.Get.title dscn in 
			 return $ Some (url, context) 
    | `Newsletter nid -> let! nletter = ohm_req_or (return None) 
			   (MNewsletter.view ~actor:(access # actor) nid) in
			 let  url = 
			   Action.url UrlClient.Newsletter.see key [ INewsletter.to_string nid ] in
			 let  context = MNewsletter.Get.title nletter in 
			 return $ Some (url, context) 
  end
  | `album  aid -> return None
  | `folder fid -> return None		
    
let () = MItem.Notify.Email.define begin fun uid u t info -> 

  let! access = ohm_req_or (return None) (CAccess.of_notification uid (t # iid)) in
  let! item   = ohm_req_or (return None) (MItem.try_get (access # actor) (t # itid)) in
  let! mail   = req_or (return None) (match item # payload with 
    | `Mail mail -> Some mail
    | `MiniPoll _ 
    | `Image _ 
    | `Doc _ 
    | `Message _ -> None) in

  let! url, context = ohm_req_or (return None) (context_of_item access item) in
					    
  return (Some (object

    method mail = let title = `Item_Notify_Title (mail # subject) in
		  let url   = CMail.link (info # id) None (snd (access # instance # key)) in

		  let! author = ohm (CAvatar.mini_profile (mail # author)) in

		  let payload = `Social (object
		    method pic  = author # pico
		    method name = author # name
		    method context = context
		    method body = `Text (mail # body) 
		  end) in

		  let body = [
		    [ `Item_Notify_Body (access # instance # name)] ;
		    [ `Item_Notify_Body2 ]
		  ] in

		  let buttons = [ VMailBrick.green `Item_Notify_Button url ] in
		  
		  return (title,payload,body,buttons)
		  
    method act _ = return url

    method item = None

  end))

end 

let () = MItem.Notify.Comment.define begin fun uid u t info -> 

  let! access = ohm_req_or (return None) (CAccess.of_notification uid (t # iid)) in
  let! itid   = ohm_req_or (return None) (MComment.item (t # cid)) in
  let! item   = ohm_req_or (return None) (MItem.try_get (access # actor) itid) in
  let! _,comm = ohm_req_or (return None) (MComment.try_get (item # id) (t # cid)) in
  
  let key = access # instance # key in 

  let! url, context = ohm_req_or (return None) (context_of_item access item) in
					    
  return (Some (object

    method mail = let title = `Comment_Notify_Title context in
		  let url   = CMail.link (info # id) None (snd key) in

		  let! author  = ohm (CAvatar.mini_profile (comm # who)) in
		  let! action  = ohm (AdLib.get `Comment_Notify_Action) in

		  let payload = `Social (object
		    method pic  = author # pico
		    method name = author # name
		    method context = action 
		    method body = `Text (comm # what) 
		  end) in

		  let body = [
		    [ `Comment_Notify_Body (access # instance # name)] ;
		    [ `Comment_Notify_Body2 ]
		  ] in

		  let buttons = [ VMailBrick.green `Comment_Notify_Button url ] in
		  
		  return (title,payload,body,buttons)
		  

    method act _ = return url

    method item = None

  end))

end 
