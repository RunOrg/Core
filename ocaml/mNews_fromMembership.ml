(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MNews_common

let () =
  let news_from_membership event = 
    
    let  before = event # before in
    let  aid = before.MMembership.Details.who in 

    (* Act as a bot for extracting group information *)
    let  gid   = IGroup.Assert.bot before.MMembership.Details.where in   
    let! group = ohm_req_or (return ()) $ MGroup.bot_get gid in
    let! eid   = req_or     (return ()) $ MGroup.Get.entity group in

    let  iid   = MGroup.Get.instance group in 

    let  real_diffs = List.filter (MMembership.relevant_change before) (event # diffs) in

    let meaning = function
      | `Invite  i -> if i # who = aid then None else Some `invite 
      | `Admin   a -> if a # who = aid
	then if a # what then Some `self_add else Some `self_remove
	else if a # what then Some `add      else Some `remove 
      | `User    u -> if u # who = aid
	then if u # what then Some `self_add else Some `self_remove
	else None
      | `Payment p -> None
    in

    let! actor = req_or (return ()) begin
      try Some (BatList.find_map
		  (function 
		    | `Invite  i -> Some (i # who)
		    | `Admin   a -> Some (a # who)
		    | `User    u -> Some (u # who)
		    | `Payment p -> Some (p # who))
		  real_diffs) 
      with _ -> None
    end in 

    let meanings    = BatList.filter_map meaning real_diffs in 

    let was_invited = match before.MMembership.Details.invited with 
      | None -> false
      | Some (invited,_,_) -> invited
    in

    let state = 
      if List.mem `self_add meanings then Some (`added None, true)
      else if List.mem `self_remove meanings then 
	if was_invited then Some (`denied, true) else Some (`removed None, true)
      else if List.mem `add meanings then Some (`added (Some actor), false)
      else if List.mem `remove meanings then Some (`removed (Some actor), false) 
      else None
    in

    let! state, public = req_or (return ()) state in 

    let payload  = `join (object
      method a = aid
      method e = eid
      method s = state 
      method t = event # time
    end) in 
    
    let access = if public then [`viewEntity eid] else [`adminEntity eid] in

    create
      ~instance:iid
      ~avatar:(Some aid)
      ~entity:(Some eid)
      ~payload
      ~time:(event # time)
      ~access
  in
  if Util.role <> `Put then
    Sig.listen MMembership.Signals.after_version news_from_membership    
