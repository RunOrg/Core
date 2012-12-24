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
	| (`Event _) as owner -> MFeed.try_by_owner owner 			      	
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
    authors = stats # authors ; 
  }))

let get_album_info owner current = 

  let! aid = ohm_req_or (return None) begin 
    match current with Some info -> return (Some info.Info.Album.id) | None ->
      match (owner : IInboxLineOwner.t) with 
	| (`Event _) as owner -> MAlbum.try_by_owner owner 			      	
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
    authors = stats # authors ; 
  }))

let get_folder_info owner current = 

  let! fid = ohm_req_or (return None) begin 
    match current with Some info -> return (Some info.Info.Folder.id) | None ->
      match (owner : IInboxLineOwner.t) with 
	| (`Event _) as owner -> MFolder.try_by_owner owner 			      	
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
    authors = stats # authors ; 
  }))
  
let schedule = O.async # define "inbox-line-refresh" IInboxLine.fmt 
  begin fun ilid -> 
    let! push = ohm_req_or (return ()) $ Tbl.transact ilid begin function
      | None -> return (None, `keep) 
      | Some current -> let! wall   = ohm $ get_wall_info   current.Line.owner current.Line.wall in 
			let! album  = ohm $ get_album_info  current.Line.owner current.Line.album in
			let! folder = ohm $ get_folder_info current.Line.owner current.Line.folder in 
			let  time = 
			  List.fold_left max current.Line.time 
			    (BatList.filter_map identity [ 
			      BatOption.bind (fun w -> w.Info.Wall.last) wall ;
			      BatOption.bind (fun a -> a.Info.Album.last) album ;
			      BatOption.bind (fun f -> f.Info.Folder.last) folder ; 
			    ])
			in
			let push  = current.Line.push + 1 in
			let fresh = Line.({ current with wall ; album ; folder ; time ; push }) in
			return (Some push,`put fresh)
    end in
    Push.schedule ilid push 
  end

let schedule ilid = 
  O.decay (schedule ilid)
