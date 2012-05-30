(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module OfUser = MDigest_ofUser
module Data   = MDigest_data

let digest_of_avatar aid = 
  let! uid = ohm_req_or (return None) $ MAvatar.get_user aid in 
  let! did = ohm $ OfUser.get uid in 
  return $ Some did

module Subscription = struct

  include MDigest_subscription

  let digest_follows = follows

  let follows cuid iid = 
    let  uid = IUser.Deduce.is_anyone cuid in 
    let! did = ohm $ OfUser.get uid in
    follows did iid

  let user_subscribe uid iid = 
    let! did = ohm $ OfUser.get uid in 
    subscribe did iid 

  let subscribe cuid iid =
    let uid = IUser.Deduce.is_anyone cuid in 
    user_subscribe uid iid 

  let unsubscribe cuid iid = 
    let  uid = IUser.Deduce.is_anyone cuid in 
    let! did = ohm $ OfUser.get uid in
    unsubscribe did iid

end

(* React to avatar status changes ---------------------------------------------------------- *) 

let on_downgrade_to_contact (_,aid,iid) = 
  let! did = ohm_req_or (return ()) $ digest_of_avatar aid in 
  Subscription.remove_all_through did iid

let _ = Sig.listen MAvatar.Signals.on_downgrade_to_contact on_downgrade_to_contact

let on_upgrade_to_member (_,aid,iid) = 
  let! did  = ohm_req_or (return ()) $ digest_of_avatar aid in 
  let! ()   = ohm $ Subscription.add_through did iid ~through:iid in
  let! iids = ohm $ MRelatedInstance.get_listened iid in 
  let! _    = ohm $ Run.list_map (fun iid' -> Subscription.add_through did iid' ~through:iid) iids in
  return () 

let _ = Sig.listen MAvatar.Signals.on_upgrade_to_member on_upgrade_to_member  
let _ = Sig.listen MAvatar.Signals.on_upgrade_to_admin on_upgrade_to_member  

(* React to network connects and disconnects ------------------------------------------------ *)

module Connection = Fmt.Make(struct
  type json t = <
    follower "f" : IInstance.t ;
    followed "o" : IInstance.t 
  >
end)

let on_network_connect = 
  let task = O.async # define "digest-network-connect" Connection.fmt begin fun connect ->
    (* Acting as bot to subscribe all members of the instance *)
    let  iid    = IInstance.Assert.bot (connect # follower) in 
    let! list   = ohm $ MAvatar.List.all_members iid in
    Run.list_iter begin fun aid ->
      let! did = ohm_req_or (return ()) $ digest_of_avatar aid in
      Subscription.add_through did (connect # followed) ~through:(connect # follower) 
    end list
  end in
  fun connect -> task (connect :> Connection.t) 

let _ = Sig.listen MRelatedInstance.Signals.after_connect on_network_connect

(* React to confirming user accounts ------------------------------------------------------- *)

let follow_runorg uid = 
  let! iid = ohm_req_or (return ()) $ MInstance.by_key "nous" in
  let! ()  = ohm $ Subscription.user_subscribe uid iid in 
  return ()

let _ = Sig.listen MUser.Signals.on_confirm (fun (uid,_) -> follow_runorg uid)
  
(* React to listening and unlistening ------------------------------------------------------ *)
  
module Following = Fmt.Make(struct
  type json t = (IDigest.t * IInstance.t)
end)

let on_unfollow = 
  let task = O.async # define "digest-network-unfollow" Following.fmt begin fun (did,iid) ->

    (* This is asynchronous processing, so check that we are STILL not following
       the instance we are unfollowing. *)
    let! follows = ohm $ Subscription.digest_follows did iid in 
    let! ()      = true_or (return ()) (not follows) in

    let! bids    = ohm $ MBroadcast.recent_ids iid ~count:Data.max_items in

    Data.remove_items did bids 

  end in
  fun (did,iid) -> task (did,iid)

let _ = Sig.listen Subscription.Signals.on_unfollow on_unfollow

let on_follow = 
  let task = O.async # define "digest-network-follow" Following.fmt begin fun (did,iid) ->

    (* This is asynchronous processing, so check that we are STILL following
       the instance we are subscribing to. *)
    let! follows = ohm $ Subscription.digest_follows did iid in 
    let! ()      = true_or (return ()) follows in

    let! items, _ = ohm $ MBroadcast.latest iid ~count:Data.max_items in

    let _, timed = List.fold_right begin fun item (last,list) -> 
      let timed = last , item in
      (item # time , timed :: list) 
    end items (0.0,[]) in

    let items = List.map begin fun (last,item) -> 
      Data.Item.({ 
	what = item # id ;
	via  = BatOption.map (#id) (item # forward) ;
	from = item # from ;
	time = item # time ;
	last ;
	size = (match item # content with 
	          | `Post c -> String.length c # body 
	 	  | `RSS  r -> OhmSanitizeHtml.length r # body) ;
      })
    end timed in

    Data.add_items did items

  end in
  fun (did,iid) -> task (did,iid)

let _ = Sig.listen Subscription.Signals.on_follow on_follow

(* React to broadcasts being posted -------------------------------------------------------- *)

module CreateTask = Fmt.Make(struct
  type json t = (IBroadcast.t * IDigest.t option)
end)

let on_create = 
  let task, define = O.async # declare "digest-network-create" CreateTask.fmt in
  let () = define begin fun (bid,did_opt) ->

    let! post = ohm_req_or (return ()) $ MBroadcast.get bid in
    let! last = ohm $ MBroadcast.previous (post # from) (post # time) in
    let  last = BatOption.default 0.0 last in

    let  item = 
      Data.Item.({ 
	what = post # id ;
	via  = BatOption.map (#id) (post # forward) ;
	from = post # from ;
	time = post # time ;
	last ;
	size =  (match post # content with 
	          | `Post c -> String.length c # body 
	 	  | `RSS  r -> OhmSanitizeHtml.length r # body) ;
      })
    in

    let iid = BatOption.default (post # from) (BatOption.map (#from) (post # forward)) in

    let! list, did_opt = ohm $ 
      Subscription.followers ?start:did_opt ~count:20 iid 
    in 
    
    let! _ = ohm $ Run.list_map (fun did -> Data.add_items did [item]) list in 

    if did_opt = None then return () else
      task (bid,did_opt)

  end in
  fun bid -> task (bid,None)

let _ = Sig.listen MBroadcast.Signals.on_create on_create

type summary = (IInstance.t * <
		  first : MBroadcast.t ;
		  next  : (IBroadcast.t * float * string) list 
                >) list

let format_summary items = 
  
  let by_iid    = ListAssoc.group_stable $ List.map (fun i -> i.Data.Item.from, i) items in

  let rec find_first (iid,items) = 
    let rec recurse = function
      | [] -> return None
      | item :: tail -> let  bid = Data.Item.(BatOption.default item.what item.via) in
			let! brc_opt = ohm $ MBroadcast.get bid in 
			match brc_opt with 
			  | None     -> recurse tail 
			  | Some brc -> return $ Some (brc, tail) 
    in
    let! brc, tail = ohm_req_or (return None) $ recurse items in 
    let! tail = ohm $ Run.list_map begin fun item -> 
      let  bid = item.Data.Item.what in 
      let! time, title = ohm_req_or (return None) $ MBroadcast.get_summary bid in 
      return $ Some (bid, time, title) 
    end (BatList.take 3 tail) in 
    
    return $ Some (iid, (object
      method first = brc
      method next  = BatList.filter_map identity tail 
    end))
  in

  let! list = ohm $ Run.list_map find_first by_iid in 
  let  list = BatList.filter_map identity list in 

  return list

let get_summary_for_showing did = 

  let! data = ohm $ Data.get did in 
  let! ()   = ohm $ Data.mark_seen did in 

  let is_unseen i = Data.(i.Item.time > data.unviewed_since) in

  let max_size  = 25 in
  let by_time   = List.sort Data.Item.(fun a b -> compare b.time a.time) data.Data.contents in
  let unseen    = List.length $ List.filter is_unseen by_time in 
  let kept      = BatList.take (max max_size unseen) by_time in 

  format_summary kept

(* Sending digests by mail --------------------------------------------------------------- *)

let get_summary_for_sending did = 

  let! data = ohm $ Data.get did in 
  let! last = ohm $ Data.mark_sent did in 

  if last <> data.Data.unsent_since then begin
    Util.log "Digest apparently locked by another process: %f <> %f"
      last data.Data.unsent_since ;
    return [] 
  end else 
    
    let is_unsent i = Data.(i.Item.time > data.unsent_since) in
    
    let by_time   = List.sort Data.Item.(fun a b -> compare b.time a.time) data.Data.contents in
    let unsent    = List.filter is_unsent by_time in 
    
    format_summary unsent

module Signals = struct
  let on_send_call,   on_send   = Sig.make (Run.list_iter identity)
end

let send_next =
  let! () = ohm $ return () in
  let! did  = ohm_req_or (return (Some 3600.0)) $ Data.next_sendable () in
  let! uids = ohm $ OfUser.reverse did in
  let! summary = ohm $ get_summary_for_sending did in 
  let! _ = ohm $ Run.list_map (fun uid -> Signals.on_send_call (uid, summary)) uids in
  return None

let () = O.async # periodic 1 send_next
