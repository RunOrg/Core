(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let actor iid self = 
  let! aid   = ohm_req_or (return None) $ MAvatar.find iid self in
  let  aid   = IAvatar.Assert.is_self aid in
  let! actor = ohm_req_or (return None) $ MAvatar.actor aid in 
  return (MActor.member actor)
