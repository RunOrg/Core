(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Payload = MNotify_payload
module Store   = MNotify_store

let to_admins payload = 
  Run.list_iter (Store.create payload) (MAdmin.list ())

let to_avatar payload aid = 
  let! details = ohm $ MAvatar.details aid in 
  let! uid = req_or (return ()) (details # who) in
  Store.create payload uid 

module ToAvatars = Fmt.Make(struct
  type json t = ( (Payload.t * IAvatar.t) list ) 
end)

let to_avatars = 
  let task = O.async # define "notify-to-avatars" ToAvatars.fmt
    (Run.list_iter (fun (payload,aid) -> to_avatar payload aid))
  in
  function
    | [] -> return ()
    | [payload, aid] -> to_avatar payload aid
    | list -> task list
 
(* Create a notification when a new instance is created ----------------------------------------------------- *)

let () = 
  let! iid = Ohm.Sig.listen MInstance.Signals.on_create in 
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in
  let! aid = ohm $ MAvatar.become_contact iid (instance # usr) in
  to_admins (`NewInstance (IInstance.decay iid, aid))

(* Create a notification when a new user is confirmed ------------------------------------------------------- *)

let () = 
  let! uid, _ = Ohm.Sig.listen MUser.Signals.on_confirm in
  to_admins (`NewUser (IUser.decay uid)) 

(* Create a notification when an user joins an instance ----------------------------------------------------- *)

let () = 
  let send (_,aid,iid) = to_admins (`NewJoin (iid,aid)) in
  Ohm.Sig.listen MAvatar.Signals.on_upgrade_to_admin  send ;
  Ohm.Sig.listen MAvatar.Signals.on_upgrade_to_member send

(* Notify user when they are added as a member or admin ----------------------------------------------------- *)

let () = 
  let react how (aid, who, iid) = 
    let! aid = req_or (return ()) aid in 
    let! details = ohm $ MAvatar.details who in
    let! uid = req_or (return ()) details # who in 
    let  payload = how (IAvatar.decay aid) iid in
    Store.create payload uid 
  in
  Ohm.Sig.listen MAvatar.Signals.on_upgrade_to_admin 
    (react (fun aid iid -> `BecomeAdmin (iid,aid))) ;
  Ohm.Sig.listen MAvatar.Signals.on_upgrade_to_member
    (react (fun aid iid -> `BecomeMember (iid,aid)))

(* Notify owner when an item is liked. ---------------------------------------------------------------------- *)

let () = 
  let! aid, what = Ohm.Sig.listen MLike.Signals.on_like in
  let `item itid = what in 
  let  bot_itid = IItem.Assert.bot itid in 
  let! author = ohm_req_or (return ()) $ MItem.author bot_itid in 
  let! details = ohm $ MAvatar.details author in 
  let! uid = req_or (return ()) details # who in 
  Store.create (`NewFavorite (`ItemAuthor, aid, IItem.decay itid)) uid

(* Notify owner and interested parties when a comment is posted --------------------------------------------- *)

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

  to_avatars list
