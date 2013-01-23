(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module Push = MInboxLine_push

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
		       let! eids = ohm $ Run.list_filter begin fun gid -> 
			 let! group = ohm_req_or (return None) $ MAvatarSet.naked_get gid in 
			 match MAvatarSet.Get.owner group with 
			   | `Entity eid -> return (Some eid) 
			   | `Event   _  -> return None
		       end  gids in 
		       return (`All :: `Groups :: List.map (fun eid -> `Group eid) eids) 
  
let schedule = O.async # define "inbox-line-refresh" IInboxLine.fmt 
  begin fun ilid -> 
    let! push = ohm_req_or (return ()) $ Tbl.transact ilid begin function
      | None -> return (None, `keep) 
      | Some current -> let! wall   = ohm $ get_wall_info   current.Line.owner current.Line.wall in 
			let! album  = ohm $ get_album_info  current.Line.owner current.Line.album in
			let! folder = ohm $ get_folder_info current.Line.owner current.Line.folder in 
			let! core   = ohm $ get_core_info   current.Line.owner in 
			let! filter = ohm $ get_filter      current.Line.owner in 
			
			let last_album = BatOption.bind (fun a -> a.Info.Album.last) album in
			let filter = if last_album <> None then `HasPics :: filter else filter in 

			let last_folder = BatOption.bind (fun f -> f.Info.Folder.last) folder in
			let filter = if last_folder <> None then `HasFiles :: filter else filter in 

			let  times  = [ 
			  BatOption.bind (fun w -> w.Info.Wall.last) wall ;
			  last_album ; 
			  last_folder ; 
			  core ; 
			] in
			
			let last  = List.fold_left max current.Line.last times in 
			let push  = current.Line.push + 1 in
			let show  = true in
			let fresh = Line.({ current with 
			  wall ; album ; folder ; last ; push ; show ; filter }) in
			return (Some push,`put fresh)
    end in
    Push.schedule ilid push 
  end

let schedule ilid = 
  O.decay (schedule ilid)
