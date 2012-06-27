(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module See     = CEvents_see
module Create  = CEvents_create
module Options = CEvents_options

let () = CClient.define UrlClient.Events.def_home begin fun access -> 
  O.Box.fill $ O.decay begin 

    (* Construct the list of entities to be displayed *)
    let! now  = ohmctx (#time) in
    let! list = ohm $ MEntity.All.get_by_kind access `Event in
    let! list = ohm $ Run.list_map begin fun entity -> 
      let! name = ohm $ CEntityUtil.name entity in
      let! pic  = ohm $ CEntityUtil.pic_small_opt entity in 
      let  date = BatOption.bind MFmt.float_of_date (MEntity.Get.date entity) in
      let! coming = ohm begin 	
	let! ()    = true_or (return None) (not (MEntity.Get.draft entity)) in
	let  gid   = MEntity.Get.group entity in 
	let! group = ohm_req_or (return None) $ MGroup.try_get access gid in
	let! group = ohm_req_or (return None) $ MGroup.Can.list group in
	let  gid   = MGroup.Get.id group in 
	let! count = ohm $ MMembership.InGroup.count gid in
	return $ Some (count # count) 
      end in            
      let status = MEntity.Get.status entity in
      return (BatOption.default now date, object
	method coming = coming 
	method date   = BatOption.map (fun t -> (t,now)) date
	method pic    = pic
	method status = status 
	method title  = name
	method url    = Action.url UrlClient.Events.see (access # instance # key) 
	  [ IEntity.to_string (MEntity.Get.id entity) ] 
      end)
    end list in 
    let list = List.map snd (List.sort (fun a b -> compare (fst b) (fst a)) list) in

    (* The URL of the options page *)
    let options = 
      if None = CAccess.admin access then None else 
	Some (Action.url UrlClient.Events.options (access # instance # key) [])
    in

    Asset_Event_ListPrivate.render (object
      method list        = list
      method url_new     = Action.url UrlClient.Events.create (access # instance # key) []
      method url_options = options
    end) 
  end
end

