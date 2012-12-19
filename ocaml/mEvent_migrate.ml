(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = MEvent_core
module Data = MEvent_data

let exists eid = 
  let! _ = ohm_req_or (return false) (E.Store.get eid) in
  return true

let create ~eid ~iid ~tid ~gid ~name ~pic ~vision ~date ~admins ~draft ~config ~address ~page ~self = 

  let! _ = ohm $ 
    E.Store.create ~id:eid ~init:E.({
      iid ;
      tid ;
      gid ;
      name ;
      pic ; 
      vision ;
      date ;
      admins ; 
      draft ;
      config ; 
      del = None 
    }) ~diffs:[] ~info:(MUpdateInfo.self self) ()
  in
  
  let! _ = ohm $ Data.create eid self ?address ~page in
  
  return () 

