(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Signals = MMembership_signals
module Details = MMembership_details

open MMembership_extract

let ensure x = true_or (return ()) x

(* ------------------------------------------------------------------------------------------------------------
   Create "you are invited" events. These will be called in the bot
   thread, so don't bother with a stepping stone task. *)

let response_expected now =  

  (* The user has not provided a response yet, nor has the administrator
     forced a "yes" response. *)
  Details.(match now.user with 
    | None -> true
    | Some (force,_,aid) -> not force && aid <> now.who)

  (* The current invitation status is "invited" *)
  && Details.(match now.invited with 
    | None -> false
    | Some (invited,_,_) -> invited) 

  (* The administrator has not denied access *)
  && Details.(match now.admin with 
    | Some (false,_,_) -> false
    | _ -> true)

module Invited = MMail.Register(struct
  include Fmt.Make(struct 
    type json t = <
      uid  : IUser.t ;
      from : IAvatar.t ; 
      iid  : IInstance.t ;
      eid  : IEvent.t ; 
      mid  : IMembership.t ;
    > ;;
  end)
  let id = IMail.Plugin.of_string "event-invite"
  let uid = (#uid) 
  let iid x = Some (x # iid)
  let from x = Some (x # from) 
  let solve x = Some (IMail.Solve.of_id (IMembership.to_id (x # mid))) 
  let item _ = true
end)

let () = 
  let! data = Sig.listen Signals.after_version in 
  let  before = data # before and now = data # after in 
  
  (* There has been a change in the invitation status. *)
  let! () = ensure Details.(before.invited <> now.invited) in

  (* A response from the user is expected *)
  let! () = ensure (response_expected now) in

  (* Fantastic ! This is a geniune invite (or re-invite). Prepare to 
     send the notification. *)

  let! details = ohm (MAvatar.details now.Details.who) in
  let! uid = req_or (return ()) (details # who) in
  let! iid = req_or (return ()) (details # ins) in

  let! from, time = req_or (return ()) (match now.Details.invited with 
    | None -> None
    | Some (_,time,aid) -> Some (aid,time)) in

  let! avset = ohm_req_or (return ()) (MAvatarSet.naked_get now.Details.where) in
  let! eid = req_or (return ()) (match MAvatarSet.Get.owner avset with 
    | `Group _ -> None
    | `Event eid -> Some eid) in

  let mwid = IMail.Wave.of_id (IEvent.to_id eid) in
  
  Invited.send_one ~time ~mwid (object
    method uid  = uid
    method from = from
    method mid  = data # mid
    method iid  = iid
    method eid  = eid
  end) 

let () = 
  let! data = Sig.listen Signals.after_version in 
  let  before = data # before and now = data # after in 

  (* A response was previously expected from the user,
     so there was probably an unsolved notification. *)
  let! () = ensure (response_expected before) in

  (* Either the user responded to the invite, or the 
     administrator now denies access *) 
  let! () = ensure (match now.Details.user with 
    | Some (_,_,aid) when aid = now.Details.who -> true
    | _ -> match now.Details.admin with 
	| Some (false,_,_) -> true
	| _ -> false) in

  (* Great ! So the invite has been processed. Mark the
     generated mail as solved. *)

  let msid = IMail.Solve.of_id (IMembership.to_id (data # mid)) in
  Invited.solve msid 

(* ------------------------------------------------------------------------------------------------------------
   Create "request pending" events. These will be called in the bot
   thread, so don't bother with a stepping stone task. *)

let admin_expected now =  

  if 
    (* The user has performed a yes request. *)
    Details.(match now.user with 
      | Some (ask,_,aid) -> ask && aid = now.who
      | None -> false)
      
    (* There is no definite admin answer, or there is an older
       negative answer. *)
    && Details.(match now.admin, now.user with 
      | None, _ -> true
      | Some (false,t1,_), Some (_,t2,_) -> t1 < t2
      | _ -> false)

  then 

    (* Check whether the avatar set is marked in "manual" mode, 
       otherwise no notifications will be sent anyway. *)
    let! avset = ohm_req_or (return false) (MAvatarSet.naked_get now.Details.where) in
    return (MAvatarSet.Get.manual avset)

  else 

    return false



module Pending = MMail.Register(struct
  include Fmt.Make(struct 
    type json t = <
      uid   : IUser.t ;
      from  : IAvatar.t ; 
      iid   : IInstance.t ;
      where : [`Event of IEvent.t | `Group of IGroup.t ] ; 
      mid   : IMembership.t ;
    > ;;
  end)
  let id = IMail.Plugin.of_string "membership-pending"
  let uid = (#uid) 
  let iid x = Some (x # iid)
  let from x = Some (x # from) 
  let solve x = Some (IMail.Solve.of_id (IMembership.to_id (x # mid))) 
  let item _ = true
end)

module SendFmt = Fmt.Make(struct
  type json t = <
    from  : IAvatar.t ; 
    iid   : IInstance.t ;
    where : [`Event of IEvent.t | `Group of IGroup.t ] ; 
    mid   : IMembership.t ;
    time  : float ;
    mwid  : IMail.Wave.t ; 
  >
end)

let send_all = MAvatarStream.iter "membership-pending-notify-loop" SendFmt.fmt 
  (fun data aid ->     
    let! ( ) = true_or (return ()) (aid <> data # from) in
    let! uid = ohm_req_or (return ()) (MAvatar.get_user aid) in
    Pending.send_one ~time:(data # time) ~mwid:(data # mwid) (object
      method from  = data # from
      method where = data # where
      method iid   = data # iid
      method uid   = uid
      method mid   = data # mid 
    end))
  (fun _ -> return ()) 

let () = 
  let! data = Sig.listen Signals.after_version in 
  let  before = data # before and now = data # after in 
  
  (* No response was previously expected. *)
  let! was_expected = ohm (admin_expected before) in
  let! () = ensure (not was_expected) in 

  (* And now, a response is expected ! *) 
  let! expected = ohm (admin_expected now) in
  let! () = ensure expected in 

  (* Prepare to send the notification. *)

  let! details = ohm (MAvatar.details now.Details.who) in
  let! iid = req_or (return ()) (details # ins) in

  let! from, time = req_or (return ()) (match now.Details.user with 
    | None -> None
    | Some (_,time,aid) -> Some (aid,time)) in

  let! avset = ohm_req_or (return ()) (MAvatarSet.naked_get now.Details.where) in
  let! stream = ohm $ MAvatarSet.Get.write_access avset in 
  let  owner = MAvatarSet.Get.owner avset in

  let  biid = IInstance.Assert.bot iid in 
  let  mwid = IMail.Wave.gen () in
  
  send_all biid stream (object
    method from  = from
    method mid   = data # mid 
    method iid   = iid
    method time  = time 
    method where = owner
    method mwid  = mwid 
  end) 

let () = 
  let! data = Sig.listen Signals.after_version in 
  let  before = data # before and now = data # after in 

  (* A response was previously expected from the admin,
     so there was probably an unsolved notification. *)
  let! expected = ohm (admin_expected before) in
  let! () = ensure expected in 

  (* No response is expected now, so the notification has been
     solved (either because the user changed their mind, or 
     because the admin acted). *) 
  let! still_expected = ohm (admin_expected now) in
  let! () = ensure (not still_expected) in 

  (* Great ! So the request has been processed. Mark the
     generated mail as solved. *)

  let msid = IMail.Solve.of_id (IMembership.to_id (data # mid)) in
  Pending.solve msid 
