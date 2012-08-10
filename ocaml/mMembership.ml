(* © 2012 RunOrg *)

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
module InGroup   = MMembership_inGroup 
module Backdoor  = MMembership_backdoor
module Field     = MMembership_field
module Grant     = MMembership_grant
module Mass      = MMembership_mass

module FieldType = MJoinFields.FieldType

(* Full type returned for more clarity ----------------------------------------------------- *)

type t = {
  where     : IGroup.t  ;
  who       : IAvatar.t ;
  admin     : (bool * float * IAvatar.t) option ;
  user      : (bool * float * IAvatar.t) option ;
  invited   : (bool * float * IAvatar.t) option ;
  paid      : (bool * float * IAvatar.t) option ;
  mustpay   : bool ;
  grant     : [ `Admin | `Token ] option ;
  admin_act : bool ;
  user_act  : bool ;
  time      : float ;
  status    : Status.t
}

let summary current reflected = {
  where     = current.Details.where ; 
  who       = current.Details.who ;
  admin     = current.Details.admin ;
  user      = current.Details.user ;
  invited   = current.Details.invited ;
  paid      = current.Details.paid ;
  mustpay   = reflected.Reflected.mustpay ;
  grant     = reflected.Reflected.grant ;
  admin_act = reflected.Reflected.admin_act ;
  user_act  = reflected.Reflected.user_act ;
  time      = reflected.Reflected.time ;
  status    = reflected.Reflected.status
}

let default ~mustpay ~group ~avatar = 
  summary (Details.default group avatar) (Reflected.default mustpay)

(* Extract values ------------------------------------------------------------------------ *)

let get mid = 
  let! data = ohm_req_or (return None) $ Versioned.get (IMembership.decay mid) in
  return $ Some (summary (Versioned.current data) (Versioned.reflected data))

let status ctx gid = 
  let  default = return `NotMember in
  let  aid  = ctx # self in
  let! mid  = ohm_req_or default $ Unique.find_if_exists gid aid in 
  let! data = ohm_req_or default $ get mid in 
  return data.status  

(* Signals ------------------------------------------------------------------------------- *)

module Signals = struct

  let allow_propagation = Util.role <> `Put

  let after_update_call, after_update = Sig.make (Run.list_iter identity)
    
  let perform_after_update = 
    let task = O.async # define "after-membership-update" IMembership.fmt 
      begin fun mid -> 
	let! data = ohm_req_or (return ()) $ get mid in
	after_update_call (mid,data)
      end in
    fun mid -> task mid

  let _ = 
    if allow_propagation then 
      Sig.listen Versioned.Signals.update begin fun t ->
	perform_after_update (Versioned.id t)
      end
	
  let after_version_call, after_version = Sig.make (Run.list_iter identity)

  let perform_after_version = 
    let task = O.async # define "after-membership-version" Versioned.VersionId.fmt 
      begin fun vid -> 
	let! version = ohm_req_or (return ()) $ Versioned.get_version vid in
	let  mid     = Versioned.version_object version in 
	let! b, a    = ohm_req_or (return ()) $
	  Versioned.version_snapshot version
	in
	let  time     = Versioned.version_time  version in    
	let  diffs    = Versioned.version_diffs version in 
	let data = object
	  method mid = mid
	  method before = b
	  method time = time
	  method diffs = diffs
	  method after = a
	end in 
	
	after_version_call data 

    end in
    fun vid -> task ~delay:5.0 vid

  let _ =
    if allow_propagation then 
      Sig.listen Versioned.Signals.version_create begin fun t ->
	perform_after_version (Versioned.version_id t)
      end

  let after_reflect_call, after_reflect = Sig.make (Run.list_iter identity)

  let perform_after_reflect = 
    let task = O.async # define "after-membership-reflect" IMembership.fmt
      begin fun mid -> 
	let! current = ohm_req_or (return ()) $ get mid in 
	after_reflect_call current 
    end in
    fun mid -> task mid

  let _ =
    if allow_propagation then 
      Sig.listen Versioned.Signals.explicit_reflect begin fun t ->
	perform_after_reflect (Versioned.id t)
      end

end

(* Identifiers from joins ---------------------------------------------------------------- *)

let as_admin gid aid = 
  let! mid = ohm $ Unique.find gid aid in
  return $ IMembership.Assert.admin mid

let as_user gid aid = 
  let! mid = ohm $ Unique.find gid aid in
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
      let! uid = ohm_req_or (return ()) $ MAvatar.get_user from in 
      let! iid = ohm_req_or (return ()) $ MAvatar.get_instance from in 
      let! g   = ohm_req_or (return ()) $ MGroup.naked_get gid in 
      let! eid = req_or     (return ()) $ MGroup.Get.entity g in
      let  p   = 
	if List.mem `Invite what then `Invite else 
	  if List.mem (`Accept true) what then
	    if List.mem (`Default true) what then `Add else `Validate
	  else `Remove
      in
      MAdminLog.log ~uid ~iid (MAdminLog.Payload.MembershipAdmin (p,eid,IAvatar.decay aid))
    end in 

    (* Apply the change *)
    let! _ = ohm $ Versioned.apply gid aid list in
    return ()

let user gid aid accept = 

  (* Log that we're doing this. *)
  let! () = ohm begin 
    let! uid = ohm_req_or (return ()) $ MAvatar.get_user aid in 
    let! iid = ohm_req_or (return ()) $ MAvatar.get_instance aid in 
    let! g   = ohm_req_or (return ()) $ MGroup.naked_get gid in 
    let! eid = req_or     (return ()) $ MGroup.Get.entity g in
    MAdminLog.log ~uid ~iid (MAdminLog.Payload.MembershipUser (accept,eid))
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

  Sig.listen Signals.after_version version_react ;
  Sig.listen Signals.after_reflect reflect_react 

(* Propagate group refresh --------------------------------------------------------------- *)

module GroupIter = Fmt.Make(struct
  type json t = (IGroup.t * Id.t option)
end)

let () = 

  let task, define = O.async # declare "after-group-update" GroupIter.fmt in
  let () = define begin fun (gid,start) -> 

    let bot_gid = IGroup.Assert.bot gid in 
    
    let! list, next = ohm $ InGroup.list_everyone ?start ~count:20 bot_gid in 
    
    let! _ = ohm $ Run.list_map begin fun aid ->
      let! mid = ohm_req_or (return ()) $ Unique.find_if_exists gid aid in
      Versioned.reflect mid
    end list in       
    
    match next with 
      | None -> return ()
      | some -> task (gid,some)    
	
  end in
  
  let refresh gid =
    let gid = IGroup.decay gid in 
    task (gid,None) 
  in

  Sig.listen MGroup.Signals.on_update refresh
    
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

(* Propagate avatar merge  ------------------------------------------------------ *)

let () = 
  let! merged_aid, into_aid = Sig.listen MAvatar.Signals.on_merge in

  let merge_membership (mid,membership) = 
    let  gid = (membership # current).Details.where in
    (* TODO : be smarter about how the data is retrieved... *)
    let!  () = ohm $ user gid into_aid true in    
    return ()
  in

  let! all = ohm $ Versioned.by_avatar merged_aid in 
  let! _   = ohm $ Run.list_iter merge_membership all in
  return () 

(* Propagate admin group binding ----------------------------------------------- *)

let () = 
  let! _, _, gid, tmpl, creator = Sig.listen MEntity.Signals.on_bind_group in 
  if tmpl = ITemplate.admin || tmpl = ITemplate.members then  
    admin ~from:creator gid creator [ `Accept true ; `Default true ]   
  else return ()
