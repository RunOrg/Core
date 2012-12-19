(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = MEvent_core

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
  
  let! _ = ohm $ Data.create eid self ~address ~page in
  
  return () 

