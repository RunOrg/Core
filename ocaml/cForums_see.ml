(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define ~back:(Action.url UrlClient.Forums.home) UrlClient.Forums.def_see 
  begin fun access -> 

    let e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in
    
    let! eid = O.Box.parse IEntity.seg in
    
    let! entity = ohm_req_or e404 $ O.decay (MEntity.try_get access eid) in
    let! entity = ohm_req_or e404 $ O.decay (MEntity.Can.view entity) in
    
    let! admin  = ohm $ O.decay (MEntity.Can.admin entity ) in
        
    let! feed   = ohm $ O.decay (MFeed.get_for_entity access eid) in
    let! feed   = ohm $ O.decay (MFeed.Can.read feed) in
    
    let! album  = ohm $ O.decay (MAlbum.get_for_entity access eid) in
    let! album  = ohm $ O.decay (MAlbum.Can.read album) in
    
    let! folder = ohm $ O.decay (MFolder.get_for_entity access eid) in
    let! folder = ohm $ O.decay (MFolder.Can.read folder) in

    let  gid = MEntity.Get.group entity in
    let! group = ohm $ O.decay (MGroup.try_get access gid) in
    let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.list group) in

    let  public = CEntityUtil.public_forum entity in 
    
    let! sidebar = O.Box.add begin 
      
      let! the_seg = O.Box.parse UrlClient.Forums.tabs in
      
      let! navig = ohm $ Run.list_map (fun seg -> 
	let! url = ohm $ O.Box.url [ fst IEntity.seg eid ; fst UrlClient.Forums.tabs seg ] in
	return (object
	  method url   = url
	  method dark  = seg = `Album
	  method cls   = if seg = the_seg then "-selected" else "" 
	  method size  = "-d0"
	  method count = "" 
	  method label = seg
	end))
	(BatList.filter_map identity 
	   [ Some `Wall ;
	     ( if album  <> None then Some `Album  else None ) ;
	     ( if folder <> None then Some `Folder else None ) ; 
	     ( if public || MEntity.Get.kind entity = `Group then None else Some `People ) 
	   ])
      in
      
      O.Box.fill (Asset_Forum_Page_Sidebar.render navig)
	
    end in
    
    let! contents = O.Box.add begin 

      let url =
	if admin <> None then 
	  Some (fun aid -> Action.url UrlClient.Forums.join (access # instance # key) 
	    [ IEntity.to_string eid ; IAvatar.to_string aid ])
	else
	  None
      in
      
      let! the_seg = O.Box.parse UrlClient.Forums.tabs in 
      match the_seg with
	| `Wall   -> let where = Some (if MEntity.Get.kind entity = `Group then `Group else `Forum) in 
		     CWall.box where access feed     
	| `Album  -> CAlbum.box access album
	| `Folder -> CFolder.box access folder
	| `People -> CPeople.forum_box ?url access group 	
	  
    end in
    
    O.Box.fill $ O.decay begin
      
      (* Top and side details -------------------------------------------------------------- *)
      
      let! name = ohm $ CEntityUtil.name entity in

      (* My own status in this group ------------------------------------------------------- *)

      let! join = ohm begin
	if public || MEntity.Get.kind entity = `Group then return None else
	  match group with None -> return None | Some group -> 
	    let! status = ohm $ MMembership.status access gid in
	    let  fields = MGroup.Fields.get group <> [] in
	    return $ 
	      Some (CJoin.Self.render eid (access # instance # key) ~gender:None ~kind:`Forum ~status ~fields)
      end in 

      (* Administrator URLs ---------------------------------------------------------------- *)
      
      let admin = 
	if admin <> None then 
	  Some (object
	    method url = Action.url UrlClient.Forums.admin (access # instance # key) [ IEntity.to_string eid ]
	  end)
	else 
	  None
      in
      
      let group = 
	if MEntity.Get.kind entity = `Group then
	  Some (Action.url UrlClient.Members.home (access # instance # key) [ IEntity.to_string eid ])
	else 
	  None
      in
      
      (* Render the page ----------------------------------------------------------------------------------- *)
      
      Asset_Forum_Page.render (object
	method sidebar    = O.Box.render sidebar
	method admin      = admin
	method group      = group 
	method title      = name
	method join       = join 
	method box        = O.Box.render contents 
      end)
    end
  end
  
