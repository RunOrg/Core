(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Versioned = MMembership_versioned
open MMembership_extract

let allow_propagation = O.role <> `Put
let delay_processing  = O.role <> `Bot

(* Running some code after each update *) 

let after_update_call, after_update = Sig.make (Run.list_iter identity)
    
let perform_after_update = 

  let perform mid = 
    let! data = ohm_req_or (return ()) $ get mid in
    after_update_call (mid,data)    
  in

  let task = O.async # define "after-membership-update" IMembership.fmt perform in 

  fun mid -> if delay_processing then task mid else perform mid 
    
let _ = 
  if allow_propagation then 
    Sig.listen Versioned.Signals.update begin fun t ->
      perform_after_update (Versioned.id t)
    end

(* Running some code for each new membership version *) 
      
let after_version_call, after_version = Sig.make (Run.list_iter identity)
  
let perform_after_version = 

  let perform vid =  
    let! version = ohm_req_or (return ()) $ Versioned.get_version vid in
    let  mid     = Versioned.version_object version in 
    let! b, a    = ohm_req_or (return ()) (Versioned.version_snapshot version) in
    
    let time  = Versioned.version_time  version in    
    let diffs = Versioned.version_diffs version in 
    let data  = object
      method mid = mid
      method before = b
      method time = time
      method diffs = diffs
      method after = a
    end in 
    
    after_version_call data 
  in

  let task = O.async # define "after-membership-version" Versioned.VersionId.fmt perform in 
  let delay = 5.0 in

  (* Always delay this, because it is quite costly, and only affects
     notifications (in theory). *)
  fun vid -> task ~delay vid 
    
let _ =
  if allow_propagation then 
    Sig.listen Versioned.Signals.version_create begin fun t ->
      perform_after_version (Versioned.version_id t)
    end
      
(* Running some code after every reflection change *)

let after_reflect_call, after_reflect = Sig.make (Run.list_iter identity)
  
let perform_after_reflect = 
  
  let perform mid = 
    let! current = ohm_req_or (return ()) $ get mid in 
    after_reflect_call current 
  in

  let task = O.async # define "after-membership-reflect" IMembership.fmt perform in 
  fun mid -> if delay_processing then task mid else perform mid 
    
let _ =
  if allow_propagation then 
    Sig.listen Versioned.Signals.explicit_reflect begin fun t ->
      perform_after_reflect (Versioned.id t)
    end
      
