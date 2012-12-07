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
module E         = MEvent_core

let create ~self ~name ?pic ?(vision=`Normal) ~iid tid = 
  assert false

module All = struct

  let future ?access iid = 
    assert false

  let undated ~access iid = 
    assert false

  let past ?access ?start ~count iid = 
    assert false

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
  assert false

let instance eid = 
  assert false
