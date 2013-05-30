(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Admin   = CGroups_admin
module Create  = CGroups_create
module ForAtom = CGroups_forAtom

let contents access = 

  let! gid = O.Box.parse IGroup.seg in
  let  actor = access # actor in 

  let! members_gid = ohm $ MPreConfigNamer.group IGroup.members (MPreConfigNamer.load (access # iid)) in 

  let gid = if IGroup.to_string gid = "" then members_gid else gid in
  
  O.Box.fill $ O.decay begin

    (* Grab the avatars and possible actions for the group --------------------------------- *)
      
    let! admin, avatars, actions, join = ohm begin

      (* Determine raw access -------------------------------------------------------------- *)

      let none = return (false, None, None, None) in

      let! group  = ohm_req_or none $ MGroup.view ~actor gid in 
      let  asid   = MGroup.Get.group group in 

      let! avset  = ohm_req_or none $ MAvatarSet.try_get actor asid in

      (* My own status in this group ------------------------------------------------------- *)

      let! join = ohm begin
	let! status = ohm $ MMembership.status actor asid in
	let  fields = MAvatarSet.Fields.get avset <> [] in
	return $ 
	  CJoin.Self.render (`Group gid) (access # instance # key) ~gender:None ~kind:`Group ~status ~fields
      end in 

      (* Url for sending messages ---------------------------------------------------------- *)

      let send_url = 
	Action.url UrlClient.Discussion.create (access # instance # key)
	  [ IGroup.to_string gid ]
      in

      let none = return (false, None, Some (object
	method admin = None
	method send  = Some send_url 
      end), Some join) in

      (* List group members ---------------------------------------------------------------- *)

      let! avset  = ohm_req_or none $ MAvatarSet.Can.list avset in
      let  asid   = MAvatarSet.Get.id avset in 

      let! avatars, _ = ohm $ MMembership.InSet.list_members ~count:100 asid in

      (* Determine if administrator or not ------------------------------------------------- *)
      
      let not_admin = return (false, Some avatars, (if avatars = [] then None else Some (object
	method admin = None
	method send  = Some send_url
      end)), Some join) in

      let! admin = ohm_req_or not_admin $ MGroup.Can.admin group in 
      
      return (true, Some avatars, Some (object
	method send = if avatars = [] then None else Some send_url
	method admin = Some (object
	  method invite = Action.url UrlClient.Members.invite (access # instance # key) 
	    [ IGroup.to_string gid ; fst UrlClient.Invite.seg `ByEmail ]
	  method admin  = Action.url UrlClient.Members.admin (access # instance # key)
	    [ IGroup.to_string gid ] 
	end)
      end), Some join)

    end in 

    (* Render the group contents ----------------------------------------------------------- *)

    let url =
      if admin then 
	Some (fun aid -> Action.url UrlClient.Members.join (access # instance # key) 
	  [ IGroup.to_string gid ; IAvatar.to_string aid ])
      else
	None
    in

    Asset_Group_Page.render (object
      method id        = gid
      method actions   = actions
      method directory = BatOption.map (CAvatar.directory ?url) avatars
      method join      = join 
    end)
  end

let () = CClient.define UrlClient.Members.def_home begin fun access -> 

  let  actor    = access # actor in
  let! contents = O.Box.add (contents access) in 

  O.Box.fill $ O.decay begin 

    let! list = ohm $ MGroup.All.visible ~actor (access # iid) in

    let! list = ohm $ Run.list_filter begin fun group -> 
      let! name = ohm $ MGroup.Get.fullname group in 
      let! count, isMember = ohm begin 	

	let  asid    = MGroup.Get.group group in 

	let! status = ohm $ MMembership.status actor asid in
	let  mbr    = status = `Member in
 
	let! avset  = ohm_req_or (return (None,mbr)) $ MAvatarSet.try_get actor asid in
	let! avset  = ohm_req_or (return (None,mbr)) $ MAvatarSet.Can.list avset in
	let  asid   = MAvatarSet.Get.id avset in 
	let! count  = ohm $ MMembership.InSet.count asid in

	return (Some count # count,mbr) 

      end in            
      let status = MGroup.Get.status group in
      return $ Some (Util.fold_all name, (isMember, object
	method id     = IGroup.to_string (MGroup.Get.id group) 
	method count  = count
	method status = (status :> VStatus.t option)  
	method name   = name
	method url    = Action.url UrlClient.Members.home (access # instance # key) 
	  [ IGroup.to_string (MGroup.Get.id group) ]  
      end))
    end list in 

    let list = List.map snd (List.sort (fun a b -> compare (fst a) (fst b)) list) in

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

