(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Admin  = CGroups_admin
module Create = CGroups_create

let contents access = 

  let! eid = O.Box.parse IEntity.seg in
  let  actor = access # actor in 

  let! members_eid = ohm begin 
    let  namer = MPreConfigNamer.load (access # iid) in
    O.decay $ MPreConfigNamer.entity IEntity.members namer
  end in 

  let eid = if IEntity.to_string eid = "" then members_eid else eid in
  
  O.Box.fill $ O.decay begin

    (* Grab the avatars and possible actions for the group --------------------------------- *)
      
    let! admin, avatars, actions, join = ohm begin

      (* Determine raw access -------------------------------------------------------------- *)

      let none = return (false, None, None, None) in

      let! entity = ohm_req_or none $ MEntity.try_get actor eid in 
      let! entity = ohm_req_or none $ MEntity.Can.view entity in 
      let  gid    = MEntity.Get.group entity in 

      let! group  = ohm_req_or none $ MGroup.try_get actor gid in

      (* My own status in this group ------------------------------------------------------- *)

      let! join = ohm begin
	let! status = ohm $ MMembership.status actor gid in
	let  fields = MGroup.Fields.get group <> [] in
	return $ 
	  CJoin.Self.render (`Entity eid) (access # instance # key) ~gender:None ~kind:`Group ~status ~fields
      end in 

      (* Url for sending messages ---------------------------------------------------------- *)

      let! send_url = ohm begin 

	if eid = members_eid then 

	  return $ Some (Action.url UrlClient.Home.home (access # instance # key) [])

	else 
	  
	  let! feed   = ohm $ MFeed.get_for_owner actor (`Entity eid) in
	  let! feed   = ohm $ MFeed.Can.read feed in
	  let! feed   = req_or (return None) feed in 
	  
	  return $ Some 
	    (Action.url UrlClient.Discussion.create (access # instance # key)
	       [ IEntity.to_string eid ])

      end in 

      let none = return (false, None, Some (object
	method admin = None
	method send  = send_url 
      end), Some join) in

      (* List group members ---------------------------------------------------------------- *)

      let! group  = ohm_req_or none $ MGroup.Can.list group in
      let  gid    = MGroup.Get.id group in 

      let! avatars, _ = ohm $ MMembership.InGroup.list_members ~count:100 gid in

      (* Determine if administrator or not ------------------------------------------------- *)
      
      let not_admin = return (false, Some avatars, (if avatars = [] then None else Some (object
	method admin = None
	method send  = send_url
      end)), Some join) in

      let! admin = ohm_req_or not_admin $ MEntity.Can.admin entity in 
      
      return (true, Some avatars, Some (object
	method send = if avatars = [] then None else send_url
	method admin = Some (object
	  method invite = Action.url UrlClient.Members.invite (access # instance # key) 
	    [ IEntity.to_string eid ; fst UrlClient.Invite.seg `ByEmail ]
	  method admin  = Action.url UrlClient.Members.admin (access # instance # key)
	    [ IEntity.to_string eid ] 
	end)
      end), Some join)

    end in 

    (* Render the group contents ----------------------------------------------------------- *)

    let url =
      if admin then 
	Some (fun aid -> Action.url UrlClient.Members.join (access # instance # key) 
	  [ IEntity.to_string eid ; IAvatar.to_string aid ])
      else
	None
    in

    Asset_Group_Page.render (object
      method id        = eid
      method actions   = actions
      method directory = BatOption.map (CAvatar.directory ?url) avatars
      method join      = join 
    end)
  end

let () = CClient.define UrlClient.Members.def_home begin fun access -> 

  let  actor    = access # actor in
  let! contents = O.Box.add (contents access) in 

  O.Box.fill $ O.decay begin 

    let! list = ohm $ MEntity.All.get_by_kind actor `Group in

    let! list = ohm $ Run.list_filter begin fun entity -> 
      let! name = ohm $ CEntityUtil.name entity in
      let! count, isMember = ohm begin 	

	let! ()     = true_or (return (None,false)) (not (MEntity.Get.draft entity)) in
	let  gid    = MEntity.Get.group entity in 

	let! status = ohm $ MMembership.status actor gid in
	let  mbr    = status = `Member in
 
	let! group  = ohm_req_or (return (None,mbr)) $ MGroup.try_get actor gid in
	let! group  = ohm_req_or (return (None,mbr)) $ MGroup.Can.list group in
	let  gid    = MGroup.Get.id group in 
	let! count  = ohm $ MMembership.InGroup.count gid in

	return (Some count # count,mbr) 

      end in            
      let status = MEntity.Get.status entity in
      if status = Some `Draft then return None else 
      return $ Some (isMember, object
	method id     = IEntity.to_string (MEntity.Get.id entity) 
	method count  = count
	method status = status 
	method name   = name
	method url    = Action.url UrlClient.Members.home (access # instance # key) 
	  [ IEntity.to_string (MEntity.Get.id entity) ]  
      end)
    end list in 

    let isMember, isNotMember = List.partition fst list in

    let create = if CAccess.admin access = None then None else
	Some (Action.url UrlClient.Members.create (access # instance # key) [])
    in

    Asset_Group_List.render (object
      method create      = create
      method isMember    = List.map snd isMember 
      method isNotMember = List.map snd isNotMember
      method box         = O.Box.render contents 
    end) 
  end
end

