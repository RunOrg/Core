(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module View    = MInboxLine_view
module ByOwner = MInboxLine_byOwner
module Refresh = MInboxLine_refresh

let () = 
  let! eid  = Sig.listen MEvent.Signals.on_bind_inboxLine in
  let! ilid = ohm $ ByOwner.get_or_create (`Event eid) in 
  Refresh.line ilid

let () = 
  let! did  = Sig.listen MDiscussion.Signals.on_bind_inboxLine in
  let! ilid = ohm $ ByOwner.get_or_create (`Discussion did) in 
  Refresh.line ilid

let () = 
  let! mid, mem = Sig.listen MMembership.Signals.after_update in 

  (* Only when a member. *)
  let! () = true_or (return ()) (mem.MMembership.status = `Member) in
  
  (* Only inside groups *)
  let  asid = mem.MMembership.where in 
  let! avset = ohm_req_or (return ()) (MAvatarSet.naked_get asid) in
  let! gid = req_or (return ()) (match MAvatarSet.Get.owner avset with
    | `Event _ -> None
    | `Group gid -> Some gid) in

  Refresh.group mem.MMembership.who gid 

let () = 
  let! item = Sig.listen MItem.Signals.on_post in 
  let! iloid = ohm_req_or (return ()) begin 
    match item # where with 
      | `feed fid -> let  fid   = IFeed.Assert.bot fid in
		     let! feed  = ohm_req_or (return None) $ MFeed.bot_get fid in
		     let  owner = MFeed.Get.owner feed in 
		     return (match owner with 
		       | `Event eid -> Some (`Event eid)
		       | `Discussion did -> Some (`Discussion did)
		       | `Newsletter nid -> Some (`Newsletter nid))      
      | `album aid -> let aid = IAlbum.Assert.bot aid in
		      let! album = ohm_req_or (return None) $ MAlbum.bot_get aid in 
		      let  owner = MAlbum.Get.owner album in
		      return (match owner with 
			| `Event eid -> Some (`Event eid))
      | `folder fid -> let fid = IFolder.Assert.bot fid in
		       let! folder = ohm_req_or (return None) $ MFolder.bot_get fid in 
		       let  owner = MFolder.Get.owner folder in
		       return (match owner with 
			 | `Event eid -> Some (`Event eid) 
			 | `Discussion did -> Some (`Discussion did)) 
  end in
  let! ilid = ohm $ ByOwner.get_or_create iloid in
  Refresh.line ilid

