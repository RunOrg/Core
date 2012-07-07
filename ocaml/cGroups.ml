(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let contents access = 

  let! eid = O.Box.parse IEntity.seg in
  
  O.Box.fill $ O.decay begin

    let! eid = ohm begin 
      if IEntity.to_string eid = "" then 
	let  namer = MPreConfigNamer.load (access # iid) in
	MPreConfigNamer.entity IEntity.members namer
      else return eid
    end in 
      
    let! avatars, actions = ohm begin

      let none = return (None, None) in

      let! entity = ohm_req_or none $ MEntity.try_get access eid in 
      let! entity = ohm_req_or none $ MEntity.Can.view entity in 
      let  gid    = MEntity.Get.group entity in 

      let! group  = ohm_req_or none $ MGroup.try_get access gid in
      let! group  = ohm_req_or none $ MGroup.Can.list group in
      let  gid    = MGroup.Get.id group in 

      let! avatars, _ = ohm $ MMembership.InGroup.avatars gid ~start:None ~count:100 in

      let no_wall = return (Some avatars, None) in

      let! feed   = ohm $ MFeed.get_for_entity access eid in
      let! feed   = ohm $ MFeed.Can.read feed in
      let! feed   = req_or no_wall feed in 

      let send_url = 
	Action.url UrlClient.Forums.see (access # instance # key)
	  [ IEntity.to_string eid ] 
      in

      let not_admin = return (Some avatars, if avatars = [] then None else Some (object
	method admin = None
	method send  = Some send_url
      end)) in

      let! admin = ohm_req_or not_admin $ MEntity.Can.admin entity in 
      
      return (Some avatars, Some (object
	method send = if avatars = [] then None else Some send_url
	method admin = Some (object
	  method invite = Action.url UrlClient.Members.invite (access # instance # key) 
	    [ IEntity.to_string eid ]
	  method admin  = Action.url UrlClient.Members.admin (access # instance # key)
	    [ IEntity.to_string eid ] 
	end)
      end))

    end in 

    Asset_Group_Page.render (object
      method id        = eid
      method actions   = actions
      method directory = BatOption.map CAvatar.directory avatars
    end)
  end

let () = CClient.define UrlClient.Members.def_home begin fun access -> 

  let! contents = O.Box.add (contents access) in 

  O.Box.fill $ O.decay begin 

    let! list = ohm $ MEntity.All.get_by_kind access `Group in

    let! list = ohm $ Run.list_map begin fun entity -> 
      let! name = ohm $ CEntityUtil.name entity in
      let! count, isMember = ohm begin 	

	let! ()     = true_or (return (None,false)) (not (MEntity.Get.draft entity)) in
	let  gid    = MEntity.Get.group entity in 

	let! status = ohm $ MMembership.status access gid in
	let  mbr    = status = `Member in
 
	let! group  = ohm_req_or (return (None,mbr)) $ MGroup.try_get access gid in
	let! group  = ohm_req_or (return (None,mbr)) $ MGroup.Can.list group in
	let  gid    = MGroup.Get.id group in 
	let! count  = ohm $ MMembership.InGroup.count gid in

	return (Some count # count,mbr) 

      end in            
      let status = MEntity.Get.status entity in
      return (isMember, object
	method id     = IEntity.to_string (MEntity.Get.id entity) 
	method count  = count
	method status = status 
	method name   = name
	method url    = Action.url UrlClient.Members.home (access # instance # key) 
	  [ IEntity.to_string (MEntity.Get.id entity) ]  
      end)
    end list in 

    let isMember, isNotMember = List.partition fst list in

    Asset_Group_List.render (object
      method create      = None
      method isMember    = List.map snd isMember 
      method isNotMember = List.map snd isNotMember
      method box         = O.Box.render contents 
    end) 
  end
end

