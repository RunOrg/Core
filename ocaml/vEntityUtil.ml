(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let name entity = 
  let unnamed = AdLib.get `Entity_Unnamed in
  let! name = ohm_req_or unnamed $ Run.opt_map TextOrAdlib.to_string (MEntity.Get.name entity) in
  return name
