(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

let get_wall_info owner current = 

  let! fid = ohm_req_or (return None) begin 
    match current with Some info -> return (Some info.Info.Wall.id) | None ->
      match (owner : IInboxLineOwner.t) with 
	| (`Event _|`Discussion _) as owner -> MFeed.try_by_owner owner 			      	
  end in 

  (* Act as a bot to extract the information. 
     Extracted information is general enough to be available to all
     viewers of the inbox line.
  *)
  let fid = IFeed.Assert.bot fid in
  
  let! stats = ohm $ MItem.stats (`feed fid) in
  
  return (Some Info.Wall.({ 
    id      = IFeed.decay fid ; 
    n       = stats # n ; 
    last    = stats # last ;
  }))

let get_album_info owner current = 

  let! aid = ohm_req_or (return None) begin 
    match current with Some info -> return (Some info.Info.Album.id) | None ->
      match (owner : IInboxLineOwner.t) with 
	| (`Event _) as owner -> MAlbum.try_by_owner owner 			      	
	| `Discussion _ -> return None
  end in 

  (* Act as a bot to extract the information. 
     Extracted information is general enough to be available to all
     viewers of the inbox line.
  *)
  let aid = IAlbum.Assert.bot aid in
  
  let! stats = ohm $ MItem.stats (`album aid) in
  
  return (Some Info.Album.({ 
    id      = IAlbum.decay aid ; 
    n       = stats # n ; 
    last    = stats # last ;
  }))

let get_folder_info owner current = 

  let! fid = ohm_req_or (return None) begin 
    match current with Some info -> return (Some info.Info.Folder.id) | None ->
      match (owner : IInboxLineOwner.t) with 
	| (`Event _ | `Discussion _) as owner -> MFolder.try_by_owner owner 			      	
  end in 

  (* Act as a bot to extract the information. 
     Extracted information is general enough to be available to all
     viewers of the inbox line.
  *)
  let fid = IFolder.Assert.bot fid in
  
  let! stats = ohm $ MItem.stats (`folder fid) in
  
  return (Some Info.Folder.({ 
    id      = IFolder.decay fid ; 
    n       = stats # n ; 
    last    = stats # last ;
  }))

let get_core_info = function 
  | `Event eid -> return None
  | `Discussion did -> let  did = IDiscussion.Assert.view did in 
		       let! discn = ohm_req_or (return None) $ MDiscussion.get did in 
		       let  aid = MDiscussion.Get.creator discn in
		       let  t   = MDiscussion.Get.update  discn in 
		       return (Some (t,aid))

let get_filter = function
  | `Event _ -> return [`All;`Events]
  | `Discussion did -> let  did = IDiscussion.Assert.view did in 
		       let! discn = ohm_req_or (return []) $ MDiscussion.get did in 
		       let  gids = MDiscussion.Get.groups discn in
		       let! eids = ohm $ Run.list_filter begin fun asid -> 
			 let! avset = ohm_req_or (return None) $ MAvatarSet.naked_get asid in 
			 match MAvatarSet.Get.owner avset with 
			   | `Group  gid -> return (Some gid) 
			   | `Event   _  -> return None
		       end  gids in 
		       return (`All :: `Groups :: List.map (fun gid -> `Group gid) eids) 
