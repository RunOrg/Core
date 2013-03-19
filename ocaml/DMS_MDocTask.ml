(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = DMS_MDocTask_core
module Can = DMS_MDocTask_can
module Get = DMS_MDocTask_get
module Set = DMS_MDocTask_set
module FieldType = DMS_MDocTask_fieldType
module All = DMS_MDocTask_all

type 'relation t = 'relation Can.t

type state = Ohm.Json.t
type process = PreConfig_Task.ProcessId.DMS.t  

module Field = struct
  type t = string
  let to_string = identity
  let of_string = identity
end

let get dtid = 
  O.decay begin
    let! found = ohm_req_or (return None) (E.Store.get (DMS_IDocTask.decay dtid)) in
    let  t = E.Store.current found in
    return (Some (Can.make dtid t))
  end
    
let createIfMissing ~process ~actor did = 
  let  create = Set.create ~process ~actor did in
  let! dtid = ohm_req_or create $ All.last did process in
  let! last = ohm_req_or create $ get dtid in
  if last.Can.data.E.active then return dtid else create

let getFromDocument dtid did = 
  let! item = ohm_req_or (return None) (get dtid) in
  if item.Can.data.E.did = DMS_IDocument.decay did then
    return (Some Can.({ id = DMS_IDocTask.Assert.view dtid ; data = item.data }))
  else
    return None
