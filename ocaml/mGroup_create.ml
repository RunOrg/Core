(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type 'relation t = 'relation MGroup_can.t

module Signals   = MGroup_signals
module Get       = MGroup_get
module Config    = MGroup_config
module E         = MGroup_core

let implementation ?pcname ?(vision=`Normal) ~self ?name ~iid tid = 

  O.decay begin 

    let  iid = IInstance.decay iid in 

    let! asid, gid = ohm begin 
      match pcname with 
	| None -> return (IAvatarSet.gen (), IGroup.gen ())
	| Some pcname -> let  pcnamer = MPreConfigNamer.load iid in 
			 let! gid  = ohm $ MPreConfigNamer.group pcname pcnamer in
			 let! asid = ohm $ MPreConfigNamer.avatarSet pcname pcnamer in 
			 return (asid, gid) 
    end in 

    let init = E.({
      iid    ;
      tid    ;
      gid    = asid ; 
      name   ;
      vision ; 
      admins = `Nobody ;
      config = Config.default ;
      del    = None ;
    }) in
    
    let! _ = ohm $ E.create gid self init [] in
    let! _ = ohm $ Signals.on_bind_group_call (iid,gid,asid,tid,MActor.avatar self) in
    let! _ = ohm $ Signals.on_bind_inboxLine_call gid in
    
    return gid

  end

let internal ?pcname ?vision ~self ~label ~iid tid = 
  Run.map ignore (implementation ?pcname ~self ~name:(`label label) ~iid tid)

let public ~self ~name ~vision ~iid tid = 
  implementation ~self ~vision ~name:(`text name) ~iid tid 
