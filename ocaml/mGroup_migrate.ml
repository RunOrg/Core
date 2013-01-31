(* {{MIGRATION}} *)
(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

module Config = MGroup_config
module Core   = MGroup_core

let () = 
  let! eid, iid, asid, self, kind, name, admins, vision, tid = Sig.listen MEntity.on_migrate in 

  let () = Util.log "<migrate> %s : migrating to group" (IEntity.to_string eid) in

  let  gid = IGroup.of_id (IEntity.to_id eid) in
  let! exists = ohm $ Core.Tbl.get gid in
  
  (* Only keep entities that were created by someone still alive. *)
  let! actor = ohm_req_or (let! () = ohm (return ()) in
			   let  () = Util.log "<migrate> %s : Unknown avatar %s" (IGroup.to_string gid) 
			     (IAvatar.to_string self) in
			   return false) $ MAvatar.actor self in 

  let! tid = req_or (let! () = ohm (return ()) in
		     let  () = Util.log "<migrate> %s : Unknown template %s" (IGroup.to_string gid) 
		       (ITemplate.to_string tid) in
		     return false)  
    (match tid with (#ITemplate.Group.t as tid) -> Some tid | _ -> None) in
			  
  (* Don't re-create discussions that have already been copied over. *)
  if exists <> None then let  () = Util.log "<migrate> %s : Already exists" (IGroup.to_string gid) in return false else
     
    let! () = ohm $ Core.create gid actor Core.({
      iid    ;
      tid    ; 
      gid    = asid ;
      name   ;
      vision ; 
      admins ; 
      config = Config.default ; 
      del    = None ; 
    }) []
    in
    
    return true
      
    
