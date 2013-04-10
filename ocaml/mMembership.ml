(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Include sub-modules --------------------------------------------------------------------- *)

module Status    = MMembership_status
module Details   = MMembership_details 
module Reflected = MMembership_reflected
module Diff      = MMembership_diff
module Data      = MMembership_data
module Versioned = MMembership_versioned
module Unique    = MMembership_unique
module InSet     = MMembership_inSet 
module Backdoor  = MMembership_backdoor
module Field     = MMembership_field
module Grant     = MMembership_grant
module Mass      = MMembership_mass
module Signals   = MMembership_signals

include MMembership_extract

module FieldType = MJoinFields.FieldType

let status actor gid = 
  let  default = return `NotMember in
  let  aid  = MActor.avatar actor in 
  let! mid  = ohm_req_or default $ Unique.find_if_exists gid aid in 
  let! data = ohm_req_or default $ get mid in 
  return data.status  

(* Identifiers from joins ---------------------------------------------------------------- *)

let as_admin gid aid = 
  let! mid = ohm $ Unique.find gid aid in
  return $ IMembership.Assert.admin mid

let as_user gid actor = 
  let! mid = ohm $ Unique.find gid (MActor.avatar actor) in
  return $ IMembership.Assert.self mid

let as_viewer gid aid = 
  let! mid = ohm $ Unique.find gid aid in
  return $ IMembership.Assert.view mid  

(* Perform changes ----------------------------------------------------------------------- *)

let admin ~from gid aid what = 
  let list = List.map (Diff.make from) what in
  if list = [] then return () else 

    (* Log that we're doing this. *)
    let! () = ohm begin 
      let  uid = IUser.Deduce.is_anyone (MActor.user from) in
      let  iid = IInstance.decay (MActor.instance from) in
      let! g   = ohm_req_or (return ()) $ MAvatarSet.naked_get gid in 
      let  own = MAvatarSet.Get.owner g in
      let  p   = 
	if List.mem `Invite what then `Invite else 
	  if List.mem (`Accept true) what then
	    if List.mem (`Default true) what then `Add else `Validate
	  else `Remove
      in
      MAdminLog.log ~uid ~iid (MAdminLog.Payload.MembershipAdmin (p,own,IAvatar.decay aid))
    end in 

    (* Apply the change *)
    let! _ = ohm $ Versioned.apply gid aid list in
    return ()

let user gid actor accept = 

  let aid = MActor.avatar actor in 

  (* Log that we're doing this. *)
  let! () = ohm begin 
    let  uid = IUser.Deduce.is_anyone (MActor.user actor) in
    let  iid = IInstance.decay (MActor.instance actor) in 
    let! g   = ohm_req_or (return ()) $ MAvatarSet.naked_get gid in 
    let  own = MAvatarSet.Get.owner g in
    MAdminLog.log ~uid ~iid (MAdminLog.Payload.MembershipUser (accept,own))
  end in 
  
  (* Apply the change *)
  let! _ = ohm $ Versioned.apply gid aid [ Diff.user aid accept ] in
  return ()
  
(* Miscellaneous imports ----------------------------------------------------------------- *)

let relevant_change data change = Diff.relevant_change data change

(* Apply membership grants --------------------------------------------------------------- *)

let () = 

  let version_react data = 
    let aid   = (data # before).Details.who in 
    let diffs = data # diffs in 
    let from  = 
      try Some (BatList.find_map begin function 
	| `Admin   a -> Some (a # who) 
	| `User    u -> Some (u # who) 
	| `Payment p -> Some (p # who) 
	| `Invite  _ -> None
      end diffs)  
      with _ -> None 
    in

    (* Acting as the author of the relevant diff *)
    let from = BatOption.map IAvatar.Assert.is_self from in 

    Grant.react ?from aid 
  in

  let reflect_react data = 
    let aid = data.who in 
    Grant.react aid 
  in

  let refresh_avatar aid = 
    Grant.react aid
  in

  Sig.listen Signals.after_version version_react ;
  Sig.listen Signals.after_reflect reflect_react ;
  Sig.listen MAvatar.Signals.refresh_grant refresh_avatar

(* Propagate group refresh --------------------------------------------------------------- *)

module GroupIter = Fmt.Make(struct
  type json t = (IAvatarSet.t * Id.t option)
end)

let () = 

  let task, define = O.async # declare "after-group-update" GroupIter.fmt in
  let () = define begin fun (gid,start) -> 

    let bot_gid = IAvatarSet.Assert.bot gid in 
    
    let! list, next = ohm $ InSet.list_everyone ?start ~count:20 bot_gid in 
    
    let! _ = ohm $ Run.list_map begin fun aid ->
      let! mid = ohm_req_or (return ()) $ Unique.find_if_exists gid aid in
      Versioned.reflect mid
    end list in       
    
    match next with 
      | None -> return ()
      | some -> task (gid,some)    
	
  end in
  
  let refresh gid =
    let gid = IAvatarSet.decay gid in 
    task (gid,None) 
  in

  Sig.listen MAvatarSet.Signals.on_update refresh
    
(* Propagate avatar obliteration ------------------------------------------------ *)

let () = 
  let! aid, _ = Sig.listen MAvatar.Signals.on_obliterate in

  let obliterate_membership (mid,membership) = 
    let gid = (membership # current).Details.where in
    let! () = ohm $ Unique.obliterate gid aid in 
    let! () = ohm $ Versioned.obliterate mid in 
    let! () = ohm $ Data.obliterate mid in
    return ()
  in

  let! all = ohm $ Versioned.by_avatar aid in 
  let! _   = ohm $ Run.list_iter obliterate_membership all in
  return () 

(* Propagate admin group binding ----------------------------------------------- *)

let () = 
  let! _, _, gid, tmpl, creator = Sig.listen MGroup.Signals.on_bind_group in 
  if tmpl = ITemplate.Group.admin || tmpl = ITemplate.Group.members then  
    let! from = ohm_req_or (return ()) $ MAvatar.actor creator in 
    admin ~from gid creator [ `Accept true ; `Default true ]   
  else return ()
