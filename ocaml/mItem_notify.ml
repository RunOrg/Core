(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MItem_common
open MItem_db

module Data     = MItem_data
module Signals  = MItem_signals
module People   = MItem_people

module Email = struct

  module Send = MMail.Register(struct
    include Fmt.Make(struct
      type json t = <
        itid : IItem.t ;
        aid  : IAvatar.t ;
	iid  : IInstance.t ; 
	uid  : IUser.t ;
	kind : [ `Mail ] 
      >
    end)
    let id = IMail.Plugin.of_string "item-published"
    let iid x = Some (x # iid) 
    let uid = (#uid) 
    let from x = Some (x # aid) 
    let solve _ = None
    let item _ = false
  end)
    
  type t = Send.t
    
  let define f = Send.define f 
    
  module SendFmt = Fmt.Make(struct
    type json t = (IItem.t * IAvatar.t * IInstance.t)
  end)
    
  let send_all = MReverseAccess.async "item-notify-loop" SendFmt.fmt 
    (fun (itid, from, iid) aid ->     
      let! ( ) = true_or (return ()) (aid <> from) in
      let! uid = ohm_req_or (return ()) (MAvatar.get_user aid) in
      let  mail = object
	method itid = itid
	method aid  = from
	method iid  = iid
	method uid  = uid
	method kind = `Mail 
      end in 
      
      (* Use item ID as the wave ID to synchronize all sendings. *)
      let mwid = IMail.Wave.of_id (IItem.to_id itid) in
      Send.send_one ~mwid mail )
    (fun _ -> return ()) 
    
  let build_notification = O.async # define "item-notify" Fmt.(IItem.fmt * IFeed.fmt)
    begin fun (itid,fid) -> 
    
      let! item = ohm_req_or (return ()) $ Tbl.get itid in 
      
      (* Make sure item has an author *)    
      let! aid  = req_or (return ()) $ Data.author item in 
      
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
	  return $ Some (iid, [ access ; `Groups (`Any,[gid])]) 
	| `Discussion did ->
	  let! discn  = ohm_req_or (return None) $ MDiscussion.get did in 
	  let! access = ohm $ MDiscussion.Satellite.access discn (`Wall `Read) in
	  let  iid    = MDiscussion.Get.iid discn in
	  return $ Some (iid, [access]) 
      end in 
    
      let biid = IInstance.Assert.bot iid in 

      (* Send to the user himself (this is intended so that the user
	 will see what the sent e-mail looks like). *)

      let! author = ohm (MAvatar.details aid) in
      let mwid = IMail.Wave.of_id (IItem.to_id itid) in
      let! () = ohm (match author # who with None -> return () | Some uid -> 
	Send.send_one ~mwid (object
	  method uid = uid
	  method aid = aid
	  method itid = itid
	  method iid  = iid 
	  method kind = `Mail
	end)) in

      (* Send to everyone else *)
      
      send_all biid access (itid, aid, iid) 
	
    end
    
  let () = 
    let! item = Ohm.Sig.listen Signals.on_post in
    
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
    
    build_notification (IItem.decay item # id, IFeed.Assert.bot fid) 
end

module Comment = struct

  include MMail.Register(struct
    include Fmt.Make(struct
      type json t = <
        uid : IUser.t ;
        iid : IInstance.t ;
	aid : IAvatar.t ;
	cid : IComment.t ;
      >
    end)
    let id = IMail.Plugin.of_string "comment"
    let iid x = Some (x # iid) 
    let uid x = x # uid
    let from x = Some (x # aid) 
    let solve _ = None
    let item _ = false
  end)

  module SendFmt = Fmt.Make(struct
    type json t = (IComment.t * IAvatar.t * IInstance.t)
  end)
    
  let send_all = MReverseAccess.async "comment-notify-loop" SendFmt.fmt 
    (fun (cid, from, iid) aid ->     
      let! ( ) = true_or (return ()) (aid <> from) in
      let! uid = ohm_req_or (return ()) (MAvatar.get_user aid) in
      let  mail = object
	method aid  = from
	method iid  = iid
	method uid  = uid
	method cid  = cid
      end in 
      
      (* Use comment ID as the wave ID to synchronize all sendings. *)
      let mwid = IMail.Wave.of_id (IComment.to_id cid) in
      send_one ~mwid mail )
    (fun _ -> return ()) 

  let () = 
    let! cid, comment = Sig.listen MComment.Signals.on_create in

    let  from = comment # who in
    let  itid = comment # on in 
    let! item = ohm_req_or (return ()) $ Tbl.get itid in

    let! it_author = req_or (return ()) $ MItem_data.author item in
    let! it_others = ohm $ People.interested itid item in 

    let  aids = List.filter ((<>) from) (BatList.sort_unique compare (it_author :: it_others)) in
    
    let  iid  = item # iid in
    let  biid = IInstance.Assert.bot iid in 
    
    send_all biid [`List aids] (IComment.decay cid, from, iid) 

end 
