(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define UrlClient.Forums.def_home begin fun access -> 
  O.Box.fill $ O.decay begin 

    let! groups = ohm $ MEntity.All.get_by_kind access `Group in 
    let! forums = ohm $ MEntity.All.get_by_kind access `Forum in 

    let! visible = ohm $ Run.list_filter begin fun entity -> 
      let read = MEntity.Satellite.access entity (`Wall `Read) in 
      match MAccess.summarize read with 
	| `Member -> return $ Some (true,entity)
	| `Admin  -> let! ok = ohm $ MAccess.test access [read] in
		     return (if ok then Some (false,entity) else None)
    end (groups @ forums) in

    let visible_public, visible_private = List.partition fst visible in 

    let render (_,entity) =
      let! title = ohm $ CEntityUtil.name entity in   
      return (object
	method url = Action.url UrlClient.Forums.see (access # instance # key) 
	  [ IEntity.to_string (MEntity.Get.id entity) ] 
	method title = title
	method messages = 0
	method group = MEntity.Get.kind entity = `Group 
	method files = None
	method pictures = None
      end)
    in

    let! visible_public  = ohm $ Run.list_map render visible_public  in
    let! visible_private = ohm $ Run.list_map render visible_private in 

    let admin = CAccess.admin access <> None in 

    let create public = 
      if admin then Some "" else None
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

