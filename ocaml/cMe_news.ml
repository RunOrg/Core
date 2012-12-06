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
	  | `Instance _ -> return $ Some (Action.url UrlClient.Home.home (access # instance # key) [])
	  | `Entity eid -> return $ Some (Action.url UrlClient.Forums.see
					    (access # instance # key) [ IEntity.to_string eid ])      
	  | `Event eid  -> return $ Some (Action.url UrlClient.Events.see
					    (access # instance # key) [ IEvent.to_string eid ])	
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

  let  uid = IUser.Deduce.is_anyone cuid in 

  (* Rendering the actual news section *)

  let  access = Util.memoize (fun iid -> Run.memo begin
    (* Acting as confirmed self to view items. *)
    let  cuid = ICurrentUser.Assert.is_old cuid in    
    let! inst = ohm_req_or (return None) (MInstance.get iid) in
    CAccess.make cuid iid inst
  end) in
  
  let count = 7 in

  let! more = O.Box.react ArchiveFmt.fmt begin fun time _ self res ->

    let! result = ohm begin 

      let! fresh, items, next = ohm (O.decay begin 
	match time with 
	  | None -> MNews.Cache.head ~count uid	
	  | Some time -> let! items, next = ohm $ MNews.Cache.rest ~count uid time in
			 return (true, items, next)
      end) in
      
      let! htmls = ohm (O.decay (Run.list_filter (render access) items)) in 
      
      match htmls, time, next with 
	| [], None, None -> begin 

	  (* There is nothing to display, and we're displaying the "first page" *)
	  Asset_News_Welcome.render ()

	end 
	| _ -> begin 

	  (* There are things to display *)

	  let more = match next with 
	    | None -> None
	    | Some time -> Some (OhmBox.reaction_endpoint self (Some time), Json.Null)
	  in
	  
	  Asset_News_More.render (object
	    method items = Html.concat htmls 
	    method more  = more
	    method old   = not fresh
	  end) 

	end

    end in

    return $ Action.json ["more", Html.to_json result] res 

  end in 

  O.Box.fill (O.decay begin

    (* User info extraction *)
    let  uid  = IUser.Deduce.can_view cuid in 
    let! user = ohm_req_or (Asset_Me_PageNotFound.render ()) $ MUser.get uid in
    let! pic  = ohm $ CPicture.small (user # picture) in

    (* Instance info extraction *)
    let uid = IUser.Deduce.can_view_inst cuid in 
    let render_instance iid = 
      let! ins = ohm_req_or (return None) $ MInstance.get iid in
      let! pic = ohm $ CPicture.small_opt (ins # pic) in
      return $ Some (object
	method pic    = pic
	method name   = ins # name
	method url    = Action.url UrlClient.Home.home (ins # key) [] 
      end)
    in

    let more_instances_url = Action.url UrlMe.Account.home owid () in
    let create_instance_url = Action.url UrlStart.home owid None in

    let rec draw_instances = function 
      | [] -> return None
      | query :: rest -> let! list = ohm query in
			 let! list = ohm $ Run.list_filter render_instance list in
			 if list = [] then draw_instances rest 
			 else return (Some (object
			   method list   = list
			   method all    = more_instances_url
			   method create = create_instance_url
			 end))
    in

    let! instances = ohm $ draw_instances [
      Run.map (List.map IInstance.decay) (MInstance.visited ~count:4 cuid) ;
      Run.map (List.map (snd |- IInstance.decay)) (MAvatar.user_instances ~count:4 ~status:`Admin uid) ;
      Run.map (List.map (snd |- IInstance.decay)) (MAvatar.user_instances ~count:4 ~status:`Token uid) ; 
    ] in

    (* News feed render seed *)
    let more = (OhmBox.reaction_endpoint more None, Json.Null) in

    Asset_News_Page.render (object
      method more = more
      method user = (object
	method pic   = pic
	method name  = user # fullname
	method email = user # email
	method url   = Action.url UrlMe.Account.home owid ()
      end)
      method instances = instances
      method create = create_instance_url
    end) 

  end)
end
