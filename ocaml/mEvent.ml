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

module Tbl = CouchDB.ReadTable(E.Store.DataDB)(IEvent)(E.Store.Raw)

let create ~self ~name ?pic ?(vision=`Normal) ~iid tid = 

  Run.edit_context (fun ctx -> (ctx :> O.ctx)) begin 

    let iid = IInstance.decay iid in 
    let eid = IEvent.gen () in
    let info = MUpdateInfo.self self in
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
    
    let! _ = ohm $ E.Store.create ~id:eid ~init ~diffs:[] ~info () in
    let! _ = ohm $ Data.create eid self in
    let! _ = ohm $ Signals.on_bind_group_call (iid,eid,gid,tid,self) in
    let! _ = ohm $ Signals.on_bind_inboxLine_call eid in
    
    return eid

  end

let get ?access eid = 
  Run.edit_context (fun ctx -> (ctx :> O.ctx)) begin 
    let! proj = ohm_req_or (return None) $ E.Store.get (IEvent.decay eid) in
    let  e = E.Store.current proj in 
    return (Can.make eid ?access e)
  end 

let view ?access eid = 
  let! event = ohm_req_or (return None) (get ?access eid) in
  Can.view event

let admin ?access eid = 
  let! event = ohm_req_or (return None) (get ?access eid) in
  Can.admin event

let delete t self = 
  Set.update t self [`Delete (IAvatar.decay self)]

let instance eid = 
  let! event = ohm_req_or (return None) (get eid) in
  return $ Some (Get.iid event)

(* {{InboxLine}} *)

let migrate_all = Async.Convenience.foreach O.async "create-event-inboxLines"
  IEvent.fmt (Tbl.all_ids ~count:100) Signals.on_bind_inboxLine_call 

let () = O.put (migrate_all ()) 
