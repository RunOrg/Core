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
    BatOption.map (fun s -> `SetState (s, aid)) state ;
    BatOption.map (fun aidopt -> `SetAssignee aidopt) assignee ;
    BatOption.map (fun aids -> `SetNotified aids) notified ;
    BatOption.map (fun data ->	
      let data = 
	BatPMap.filteri 
	  (fun k v -> v <> (try BatPMap.find k t.Can.data.E.data with Not_found -> Json.Null)) 
	  data 
      in
      `SetData data) data
  ] in
  if diffs <> [] then 
    O.decay begin
      let! _ = ohm $ E.Store.update ~id ~diffs ~info () in
      return () 
    end
  else
    return () 
      
let createIfMissing ~process ~actor did = 
  assert false
    
