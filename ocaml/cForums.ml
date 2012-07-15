(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module See = CForums_see
module Admin = CForums_admin

let () = CClient.define UrlClient.Forums.def_home begin fun access -> 
  O.Box.fill $ O.decay begin 

    let! members_eid = ohm begin 
      let  namer = MPreConfigNamer.load (access # iid) in
      MPreConfigNamer.entity IEntity.members namer
    end in 

    let! groups = ohm $ MEntity.All.get_by_kind access `Group in 
    let! forums = ohm $ MEntity.All.get_by_kind access `Forum in 

    let! visible = ohm $ Run.list_filter begin fun entity -> 
      if IEntity.decay (MEntity.Get.id entity) = members_eid then return None else 
	let read = MEntity.Satellite.access entity (`Wall `Read) in 
	let public = match MAccess.summarize read with 
	  | `Member -> true 
	  | `Admin  -> false 
	in
	let! feed = ohm $ MFeed.get_for_entity access (MEntity.Get.id entity) in
	let! feed = ohm_req_or (return None) $ MFeed.Can.read feed in 
	let! last = ohm $ MItem.last (`feed (MFeed.Get.id feed)) in
	return $ Some (public,(entity,last))
    end (forums @ groups) in
    
    let visible_public, visible_private = List.partition fst visible in 

    let! now = ohmctx (#time) in

    let render (_,(entity,last)) =
      let! title = ohm $ CEntityUtil.name entity in   
      let! last = ohm begin 
	match last with None -> return None | Some item -> 
	  let! author = req_or (return None) (MItem.author (item # payload)) in
	  let! p = ohm $ CAvatar.mini_profile author in
	  return $ Some (object
	    method pic  = p # pico
	    method name = p # name
	    method time = (item # time, now)
	  end)
      end in 
      return (object
	method url = Action.url UrlClient.Forums.see (access # instance # key) 
	  [ IEntity.to_string (MEntity.Get.id entity) ] 
	method title = title
	method group = MEntity.Get.kind entity = `Group 
	method files = None
	method pictures = None
	method last = last
      end)
    in

    let! visible_public  = ohm $ Run.list_map render visible_public  in
    let! visible_private = ohm $ Run.list_map render visible_private in 

    let admin = CAccess.admin access <> None in 

    let create public = 
      if admin then Some (object
	method public = public
	method url = Json.Null
      end) else None
    in
      
    Asset_Forum_List.render (object
      method pub = object
	method list = visible_public
	method create = create true
      end
      method priv = object
	method list = visible_private
	method create = create false
      end
    end) 

  end
end

