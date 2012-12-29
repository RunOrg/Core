(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type 'relation t = 'relation MEvent_can.t

module Vision    = MEvent_vision 
module Signals   = MEvent_signals
module Can       = MEvent_can 
module Data      = MEvent_data
module Get       = MEvent_get
module Satellite = MEvent_satellite
module Set       = MEvent_set
module Config    = MEvent_config
module All       = MEvent_all
module E         = MEvent_core

let create ~self ~name ?pic ?(vision=`Normal) ~iid tid = 

  O.decay begin 

    let iid = IInstance.decay iid in 
    let eid = IEvent.gen () in
    let gid  = IGroup.gen () in
    
    let init = E.({
      iid    ;
      tid    ;
      gid    ;
      name   ;
      pic    = BatOption.map IFile.decay pic ;
      vision ;
      date   = None ;
      admins = `Nobody ;
      draft  = true ;
      config = Config.default ;
      del    = None ;
    }) in
    
    let! _ = ohm $ E.create eid self init [] in
    let! _ = ohm $ Data.create eid self in
    let! _ = ohm $ Signals.on_bind_group_call (iid,eid,gid,tid,MActor.avatar self) in
    let! _ = ohm $ Signals.on_bind_inboxLine_call eid in
    
    return eid

  end

include HEntity.Get(Can)(E)

let delete t self = 
  Set.update [`Delete (IAvatar.decay (MActor.avatar self))] t self 

let instance eid = 
  let! event = ohm_req_or (return None) (get eid) in
  return $ Some (Get.iid event)

(* {{InboxLine}} *)

let migrate_all = Async.Convenience.foreach O.async "create-event-inboxLines"
  IEvent.fmt (E.Tbl.all_ids ~count:100) Signals.on_bind_inboxLine_call 

let () = O.put (migrate_all ()) 
