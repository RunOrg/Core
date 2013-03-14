(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = DMS_MDocTask_core
module Can = DMS_MDocTask_can

let info ?state ?assignee ?notified ?data t actor = 
  let info = MUpdateInfo.self (MActor.avatar actor) in
  let aid = IAvatar.decay (MActor.avatar actor) in
  let id = DMS_IDocTask.decay t.Can.id in 
  let diffs = BatList.filter_map identity [
    BatOption.bind (fun s -> 
      let (s',_,_) = t.Can.data.E.state in
      if s = s' then None else Some (`SetState (s, aid))) state ;
    BatOption.bind (fun aidopt -> 
      if aidopt = t.Can.data.E.assignee then None else Some (`SetAssignee aidopt)) assignee ;
    BatOption.bind (fun aids -> 
      let aids = List.sort compare aids in 
      if aids = t.Can.data.E.notified then None else Some (`SetNotified aids)) notified ;
    BatOption.bind (fun data ->	
      let data = 
	BatPMap.filteri 
	  (fun k v -> v <> (try BatPMap.find k t.Can.data.E.data with Not_found -> Json.Null)) 
	  data 
      in
      if BatPMap.is_empty data then None else Some (`SetData data)) data
  ] in
  if diffs <> [] then 
    O.decay begin
      let! _ = ohm $ E.Store.update ~id ~diffs ~info () in
      return () 
    end
  else
    return () 
      
let create ~process ~actor did = 
  let! now = ohmctx (#time) in
  let id = DMS_IDocTask.gen () in
  let info = MUpdateInfo.self (MActor.avatar actor) in
  let iid = IInstance.decay (MActor.instance actor) in
  let aid = IAvatar.decay (MActor.avatar actor) in
  let diffs = [] in
  let state = (PreConfig_Task.DMS.states process) # initial in
  let active = not ((PreConfig_Task.DMS.states process) # final state) in
  let init = E.({
    iid ;
    did = DMS_IDocument.decay did ;
    state = (state, aid, now) ; 
    active ;
    process ;
    data = BatPMap.empty ;
    assignee = None ;
    notified = [] ;
    created = (aid, now) ;    
  }) in
  let! _ = ohm $ O.decay (E.Store.create ~id ~diffs ~init ~info ()) in
  return (DMS_IDocTask.Assert.view id)
    
