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

(* Notify user when they are added as a member or admin ------------------------------------- *)

let () = 
  let react how (aid, who, iid) = 
    let! aid = req_or (return ()) aid in 
    let! () = true_or (return ()) (IAvatar.decay aid <> IAvatar.decay who) in
    let! details = ohm $ MAvatar.details who in
    let! uid = req_or (return ()) details # who in 
    let  payload = how (IAvatar.decay aid) iid in
    Store.create payload uid 
  in
  Ohm.Sig.listen MAvatar.Signals.on_upgrade_to_admin 
    (react (fun aid iid -> `BecomeAdmin (iid,aid))) ;
  Ohm.Sig.listen MAvatar.Signals.on_upgrade_to_member
    (react (fun aid iid -> `BecomeMember (iid,aid)))

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

(* Notify owner and interested parties when a comment is posted ----------------------------- *)

let () = 
  let! cid, comm = Ohm.Sig.listen MComment.Signals.on_create in 

  let  aid       = comm # who in
  let  bot_itid  = IItem.Assert.bot (comm # on) in
  let! it_author = ohm_req_or (return ()) $ MItem.author bot_itid in
  let! it_others = ohm $ MItem.interested bot_itid in 
  let  it_others = List.filter (fun aid' -> aid' <> it_author && aid' <> aid) it_others in 
 
  let author_payload = (`NewComment (`ItemAuthor,   IComment.decay cid)) in
  let others_payload = (`NewComment (`ItemFollower, IComment.decay cid)) in

  let list = List.map (fun aid -> (others_payload, aid)) it_others in
  let list = if it_author <> aid then (author_payload, it_author) :: list else list in

  to_avatars (INotifyStats.of_id (IComment.to_id cid)) list

(* Notify interested parties when an item with an author is posted on a feed ---------------- *)

let push_item_task = O.async # define "notify-push-item" Fmt.(IItem.fmt * IFeed.fmt)
  begin fun (itid,fid) -> 
    
    (* Make sure item has an author *)
    let! aid = ohm_req_or (return ()) $ MItem.author itid in 
    
    (* Entity members receive posts written on entity walls *)
    let! interested = ohm begin
      let! feed = ohm_req_or (return []) $ MFeed.bot_get fid in 
      match MFeed.Get.owner feed with 
	| `of_instance iid ->
	  let  iid = IInstance.Assert.bot iid in
	  MAvatar.List.all_members iid 
	| `of_message _ -> return []
	| `of_entity eid -> 
	  let  eid    = IEntity.Assert.bot eid in 
	  let! entity = ohm_req_or (return []) $ MEntity.bot_get eid in 
	  let  gid    = IGroup.Assert.bot $ MEntity.Get.group entity in 
	  let! list   = ohm $ MMembership.InGroup.all gid `Any in
	  return $ List.map snd list	
    end in 
    
    (* Preferences further determine who does or does not receive posts. *)
    let! preferences = ohm $ MBlock.all_special (`Feed (IFeed.decay fid)) in
    
    let block = 
      List.fold_left (fun acc aid -> BatPSet.add aid acc) (BatPSet.add aid BatPSet.empty)
	(preferences # block)
    in
    
    let aids = 
      BatList.sort_unique compare
	(List.filter (fun aid -> not (BatPSet.mem aid block)) (interested @ preferences # send))
    in
    
    let payload = `NewWallItem (`WallReader, IItem.decay itid) in
    
    let list = List.map (fun aid -> payload, aid) aids in
    
    to_avatars (INotifyStats.of_id (IItem.to_id itid)) list
      
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
    | `Message _ 
    | `MiniPoll _ 
    | `Image _ 
    | `Doc _ 
    | `Chat _ 
    | `ChatReq _ -> false
  end in 

  push_item_task (item # id, IFeed.Assert.bot fid) 

(* Notify interested parties when membership changes --------------------------------------- *)

let push_invite_task inviter_aid invited_aid gid = 

  if inviter_aid = invited_aid then return () else

    let! group = ohm_req_or (return ()) $ MGroup.naked_get gid in 
    let! eid   = req_or (return ()) $ MGroup.Get.entity group in 
    
    let payload = `EntityInvite (eid, inviter_aid) in
    to_avatar payload invited_aid (INotifyStats.gen ()) 

let push_request_task aid eid admins = 

  (* We're sending a notification, so we can reverse the rights ! *)
  let! iid = ohm_req_or (return ()) $ MEntity.instance eid in 
  let  iid = IInstance.Assert.rights iid in 

  let! admins = ohm $ MReverseAccess.reverse iid [admins] in

  let payload = `EntityRequest (eid, aid) in
  to_avatars (INotifyStats.gen ()) (List.map (fun aid -> payload, aid) admins)

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
      let! group = ohm_req_or (return ()) $ MGroup.naked_get 
	((change # after).MMembership.Details.where) in
      
      if MGroup.Get.manual group then 

	let! eid = req_or (return ()) $ MGroup.Get.entity group in 
	let! access = ohm $ MGroup.Get.write_access group in 

	(* Manual validation is on ! *)
	push_request_task
	  ((change # after).MMembership.Details.who)  
	  eid access
	
      else
	return ()

    else
      return ()

  else
    return ()
