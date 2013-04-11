(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Payload = MNotify_payload
module Store   = MNotify_store

let to_admins payload = 
  Run.list_iter (Store.create payload) (MAdmin.list ())

let to_avatar payload aid nsid = 
  let! details = ohm $ MAvatar.details aid in 
  let! uid = req_or (return ()) (details # who) in
  Store.create ~stats:nsid payload uid 

module ToAvatars = Fmt.Make(struct
  type json t = ( (Payload.t * IAvatar.t) list * INotifyStats.t) 
end)

let to_avatars = 
  let task = O.async # define "notify-to-avatars" ToAvatars.fmt
    (fun (list,nsid) -> 
      Run.list_iter (fun (payload,aid) -> to_avatar payload aid nsid) list)
  in
  fun nsid -> 
    function
      | [] -> return ()
      | [payload, aid] -> to_avatar payload aid nsid
      | list -> task (list,nsid)
 
module ToAccess = Fmt.Make(struct
  type json t = (IInstance.t * Payload.t * MAccess.t * IAvatar.t option * INotifyStats.t * IAvatar.t option) 
end)

let to_access = 
  let access_step = 10 in
  let task, define = O.async # declare "notify-to-access" ToAccess.fmt in
  let () = define begin fun (iid, payload, access, start, nsid, except) ->
    let  biid = IInstance.Assert.bot iid in 
    let! list, next = ohm $ MReverseAccess.reverse biid ?start ~count:access_step [access] in

    let! () = ohm $ Run.list_iter (fun aid -> 
      if Some aid = except then return () else to_avatar payload aid nsid
    ) list in

    if next = None then return () else task (iid,payload,access,next,nsid,except) 
  end in 
  fun iid payload nsid ?except access -> 
    task (iid, payload, access, None, nsid, except) 

(* Create a notification when a new instance is created ------------------------------------- *)

let () = 
  let! iid = Ohm.Sig.listen MInstance.Signals.on_create in 
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in
  let! aid = ohm $ MAvatar.become_contact iid (instance # usr) in
  to_admins (`NewInstance (IInstance.decay iid, aid))

(* Create a notification when a new user is confirmed --------------------------------------- *)

let () = 
  let! uid, _ = Ohm.Sig.listen MUser.Signals.on_confirm in
  to_admins (`NewUser (IUser.decay uid)) 

(* Notify owner when an item is liked. ------------------------------------------------------ *)

let () = 
  let! aid, what = Ohm.Sig.listen MLike.Signals.on_like in
  let `item itid = what in 
  let  bot_itid = IItem.Assert.bot itid in 
  let! author = ohm_req_or (return ()) $ MItem.author bot_itid in 
  let! () = true_or (return ()) (IAvatar.decay author <> IAvatar.decay aid) in
  let! details = ohm $ MAvatar.details author in 
  let! uid = req_or (return ()) details # who in 
  Store.create (`NewFavorite (`ItemAuthor, aid, IItem.decay itid)) uid

(* Notify interested parties when an item with an author is posted on a feed ---------------- *)

let push_item_task = O.async # define "notify-push-item" Fmt.(IItem.fmt * IFeed.fmt)
  begin fun (itid,fid) -> 
    
    (* Make sure item has an author *)
    let! aid = ohm_req_or (return ()) $ MItem.author itid in 
    
    let! iid, access = ohm_req_or (return ()) $ begin
      let! feed = ohm_req_or (return None) $ MFeed.bot_get fid in 
      match MFeed.Get.owner feed with 
	| `Event eid -> 
	  (* For events, don't send to all readers (because event could be public), 
	     send to any people in the event and to event moderators. *)
	  let! event  = ohm_req_or (return None) $ MEvent.get eid in 
	  let! access = ohm $ MEvent.Satellite.access event (`Wall `Manage) in
	  let  iid    = MEvent.Get.iid event in 
	  let  gid    = MEvent.Get.group event in 
	  return $ Some (iid, `Union [ access ; `Groups (`Any,[gid])]) 
	| `Discussion did ->
	  let! discn  = ohm_req_or (return None) $ MDiscussion.get did in 
	  let! access = ohm $ MDiscussion.Satellite.access discn (`Wall `Read) in
	  let  iid    = MDiscussion.Get.iid discn in
	  return $ Some (iid, access) 
    end in 
    
    let payload = `NewWallItem (`WallReader, IItem.decay itid) in
    
    to_access iid payload (INotifyStats.of_id (IItem.to_id itid)) ~except:aid access
      
  end
  
let () = 
  let! item = Ohm.Sig.listen MItem.Signals.on_post in
  
  (* Only push items that were posted to feeds. *)
  let! fid = req_or (return ()) begin match item # where with
    | `feed fid -> Some fid 
    | `album _ | `folder _ -> None
  end in 

  (* Only push items that have an e-mail payload attached. *)
  let! () = true_or (return ()) begin match item # payload with 
    | `Mail _ -> true
    | `Message _ 
    | `MiniPoll _ 
    | `Image _ 
    | `Doc _ -> false
  end in 

  push_item_task (item # id, IFeed.Assert.bot fid) 

(* Notify interested parties when membership changes --------------------------------------- *)

let push_invite_task inviter_aid invited_aid gid = 

  if inviter_aid = invited_aid then return () else

    let! group = ohm_req_or (return ()) $ MAvatarSet.naked_get gid in 
    let! eid   = req_or (return ()) begin 
      match MAvatarSet.Get.owner group with
	| `Event  eid -> Some eid 
	| `Group   _  -> None
     end in 

     let payload = `EventInvite (eid, inviter_aid) in
     to_avatar payload invited_aid (INotifyStats.gen ()) 

let push_request_task aid owner admins = 

   let! iid = ohm_req_or (return ()) begin match owner with 
    | `Group  gid -> MGroup.instance gid 
    | `Event  eid -> MEvent.instance eid
  end in 

  let payload = match owner with 
    | `Event eid -> `EventRequest (eid, aid) 
    | `Group gid -> `GroupRequest (gid, aid)
  in

  to_access iid payload (INotifyStats.gen ()) admins

let () = 
  let! change = Ohm.Sig.listen MMembership.Signals.after_version in 
  if List.exists (function `Invite _ -> true | _ -> false) (change # diffs) then

    match (change # after).MMembership.Details.invited with 
      | None -> return ()
      | Some (_,_,who) -> 

	(* An invite was sent ! *)
	push_invite_task
	  who 
	  ((change # after).MMembership.Details.who) 
	  ((change # after).MMembership.Details.where) 

  else if List.exists (function `User w -> w # what | _ -> false) (change # diffs) then

    (* This might be a join request. Let's check whether it is *)
    if MMembership.Details.(
      (change # after).admin = None 
      && (match (change # before).user with Some (b,_,_) -> not b | _ -> true))
    then 
      (* This certainly looks like a join request, but does the group enforce
	 manual validation ? We do this check last because it costs an additional
	 database query. *)
      let! group = ohm_req_or (return ()) $ MAvatarSet.naked_get 
	((change # after).MMembership.Details.where) in
      
      if MAvatarSet.Get.manual group then 

	let  owner  = MAvatarSet.Get.owner group in 
	let! access = ohm $ MAvatarSet.Get.write_access group in 

	(* Manual validation is on ! *)
	push_request_task
	  ((change # after).MMembership.Details.who)  
	  owner access
	
      else
	return ()

    else
      return ()

  else
    return ()
