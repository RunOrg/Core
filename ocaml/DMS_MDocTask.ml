(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = DMS_MDocTask_core
module Can = DMS_MDocTask_can
module Get = DMS_MDocTask_get
module Set = DMS_MDocTask_set
module FieldType = DMS_MDocTask_fieldType

type 'relation t = 'relation Can.t

type state = Ohm.Json.t

module Field = struct
  type t = string
  let to_string = identity
  let of_string = identity
end

module All = struct
  let by_document _ = assert false
  let active _ _ = assert false
end

let createIfMissing ~process ~actor did = 
  Set.createIfMissing ~process ~actor did 

let get dtid = 
  O.decay begin
    let! found = ohm_req_or (return None) (E.Store.get (DMS_IDocTask.decay dtid)) in
    let  t = E.Store.current found in
    return (Some (Can.make dtid t))
  end
    

