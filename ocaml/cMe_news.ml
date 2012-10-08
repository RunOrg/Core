(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

let render_item access itid = 

  let none = return None in 

  let! iid = ohm_req_or none $ MItem.iid itid in 
  let! access = ohm_req_or none $ access iid in 

  let! item = ohm_req_or none $ MItem.try_get access itid in 

  let! now  = ohmctx (#time) in

  let! aid  = req_or none $ MItem.author_by_payload (item # payload) in 
  let! author = ohm $ CAvatar.mini_profile aid in
  let! name = req_or none (author # nameo) in 

  let! body = req_or none begin 
    match item # payload with 
      | `Mail m -> Some (m # body)
      | `MiniPoll p -> Some (p # text)
      | `Message m -> Some (m # text)
      | `Image _ 
      | `Doc _
      | `Chat _
      | `ChatReq _ -> None 
  end in 

  let! url = ohm_req_or none begin 
    match item # where with 
      | `feed fid -> begin
	let! feed = ohm_req_or none $ MFeed.try_get access fid in 
	match MFeed.Get.owner feed with 
	  | `of_instance _ -> return $ Some (Action.url UrlClient.Home.home (access # instance # key) [])
	  | `of_entity eid -> begin 
	    let! entity = ohm_req_or none $ MEntity.try_get access eid in 
	    return $ Some (Action.url 
			     (if MEntity.Get.kind entity = `Event then UrlClient.Events.see
			      else UrlClient.Forums.see) 
			     (access # instance # key) [ IEntity.to_string eid ])
	  end 
	  | `of_message  _ -> return None
      end
      | `album  aid -> return None
      | `folder fid -> return None			
  end in 

  let! html = ohm $ Asset_News_Item.render (object
    method body = OhmText.cut ~ellipsis:"…" 200 body
    method name = name
    method date = (item # time, now)
    method url  = url
    method pic  = author # pico
  end) in
  return (Some html)

let render access = function
  | `Item itid -> render_item access itid

module ArchiveFmt = Fmt.Make(struct type json t = (float option) end)

let () = define UrlMe.News.def_home begin fun owid cuid ->

  let  access = Util.memoize (fun iid -> Run.memo begin
    (* Acting as confirmed self to view items. *)
    let  cuid = ICurrentUser.Assert.is_old cuid in    
    let! inst = ohm_req_or (return None) (MInstance.get iid) in
    CAccess.make cuid iid inst
  end) in
  
  let  uid = IUser.Deduce.is_anyone cuid in 
  
  let count = 7 in

  let! more = O.Box.react ArchiveFmt.fmt begin fun time _ self res ->

    let! fresh, items, next = ohm (O.decay begin 
      match time with 
	| None -> MNews.Cache.head ~count uid	
	| Some time -> let! items, next = ohm $ MNews.Cache.rest ~count uid time in
		       return (true, items, next)
    end) in

    let! htmls = ohm (O.decay (Run.list_filter (render access) items)) in 

    let more = match next with 
      | None -> None
      | Some time -> Some (OhmBox.reaction_endpoint self (Some time), Json.Null)
    in

    let! result = ohm $ Asset_News_More.render (object
      method items = Html.concat htmls 
      method more  = more
      method old   = not fresh
    end) in

    return $ Action.json ["more", Html.to_json result] res 

  end in 

  O.Box.fill (O.decay begin

    let more = (OhmBox.reaction_endpoint more None, Json.Null) in

    Asset_News_Page.render (object
      method more = more
    end) 

  end)
end
