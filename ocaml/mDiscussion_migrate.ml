(* {{MIGRATION}} *)
(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

module Core = MDiscussion_core

let () = 
  let! iid, uid, name = Sig.listen MInstance.on_migrate in 
  return true

let () = 
  let! eid, iid, gid, self, kind, name = Sig.listen MEntity.on_migrate in 

  let owner = `Entity eid in 

  let! fid_opt = ohm $ MFeed.try_by_owner owner in 
  let! feed_last = ohm (match fid_opt with 
    | None -> return None
    | Some fid -> let! stats = ohm $ MItem.stats (`feed (IFeed.Assert.bot fid)) in
		  return (BatOption.map fst (stats # last)) 
  ) in
			
  let! flid_opt = ohm $ MFolder.try_by_owner owner in 
  let! folder_last = ohm (match flid_opt with
    | None -> return None
    | Some flid -> let! stats = ohm $ MItem.stats (`folder (IFolder.Assert.bot flid)) in
		   return (BatOption.map fst (stats # last))
  ) in

  (* Only keep entities which have messages or files. *)
  let! last = req_or (return false) (max feed_last folder_last) in
    
  let did = IDiscussion.of_id (IEntity.to_id eid) in
  let! exists = ohm $ Core.Tbl.get did in
  
  (* Only keep entities that were created by someone still alive. *)
  let! actor = ohm_req_or (return false) $ MAvatar.actor self in 

  (* Don't re-create discussions that have already been copied over. *)
  if exists <> None then return false else

    let! () = ohm begin
      let! fid = req_or (return ()) fid_opt in
      MFeed.migrate_owner (IFeed.Assert.bot fid) (`Discussion did) 
    end in
     
    let! () = ohm begin 
      let! flid = req_or (return ()) flid_opt in
      MFolder.migrate_owner (IFolder.Assert.bot flid) (`Discussion did) 
    end in 
      
    let! () = ohm $ Run.edit_context (fun ctx -> (object
      method time       = last
      method date       = Date.of_timestamp last
      method couchDB    = ctx # couchDB
      method async      = ctx # async
      method adlib      = ctx # adlib	
      method track_logs = ctx # track_logs 
    end)) begin 
      Core.create did actor Core.({
	iid   ;
	gids  = [] ;
	title = "" ;
	body  = `Text "" ;
	time  = last ;
	crea  = IAvatar.decay self ;
	del   = None
      }) [
	`SetTitle ("Archive - " ^ name) ;
	`AddGroups [gid] ;
      ]
    end in
    
    return true
      
    
