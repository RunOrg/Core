(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type 'relation t = 'relation MGroup_can.t

module Create = MGroup_create

let create_initial = 
  let task = O.async # define "create-initial-entities" Fmt.(IInstance.fmt * IAvatar.fmt) 
    begin fun (iid,aid) -> 

      (* Act as the creator... *)
      let aid = IAvatar.Assert.is_self aid in 
    
      let! instance = ohm_req_or (return ()) $ MInstance.get iid in 
      let! self     = ohm_req_or (return ()) $ MAvatar.actor aid in 
      let  created  = PreConfig_Vertical.create (instance # ver) in
      
      Run.list_iter (fun (tmpl,label) -> Create.internal ~self ~label ~iid tmpl) created
	
    end in 
  fun iid aid -> task (IInstance.decay iid, aid)

let _ = 

  let! iid = Sig.listen MInstance.Signals.on_create in
  
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in
  
  let! aid = ohm $ MAvatar.become_admin iid (instance # usr) in

  (* Act as the creator... *)
  let  creator = IAvatar.Assert.is_self aid in
  let! self    = ohm_req_or (return ()) $ MAvatar.actor creator in 
  
  let! () = ohm $ create_initial iid creator in 

  let! () = ohm $ Create.internal ~pcname:IGroup.admin ~self ~label:`EntityAdminName ~vision:`Private 
    ITemplate.Group.admin ~iid:(IInstance.decay iid) 
  in

  let! () = ohm $ Create.internal ~pcname:IGroup.members ~self ~label:`EntityMembersName
    ITemplate.Group.members ~iid:(IInstance.decay iid) 
  in

  return ()  
