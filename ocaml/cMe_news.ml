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

let () = define UrlMe.News.def_home begin fun owid cuid ->
  O.Box.fill (O.decay begin

    let  access = Util.memoize (fun iid -> Run.memo begin
      (* Acting as confirmed self to view items. *)
      let  cuid = ICurrentUser.Assert.is_old cuid in    
      let! inst = ohm_req_or (return None) (MInstance.get iid) in
      CAccess.make cuid iid inst
    end) in

    let  uid = IUser.Deduce.is_anyone cuid in 

    let! fresh, items, next = ohm (MNews.Cache.head ~count:10 uid) in
    let! htmls = ohm (Run.list_filter (render access) items) in 
    let  html  = Html.concat htmls in

    return html

  end)
end
