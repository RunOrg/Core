(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let contents access = 

  let! eid = O.Box.parse IEntity.seg in
  
  O.Box.fill begin
    Asset_Group_Page.render (object
      method id = eid
      method directory = return ignore
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

