(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let name entity = 
  let unnamed = AdLib.get `Entity_Unnamed in
  let! name = ohm_req_or unnamed $ Run.opt_map TextOrAdlib.to_string (MEntity.Get.name entity) in
  return name

let pic_large entity = 
  CPicture.large (MEntity.Get.picture entity)

let desc entity = 
  let  eid  = MEntity.Get.id entity in
  let! data = ohm_req_or (return None) $ MEntity.Data.get eid in 
  let  tmpl = MEntity.Get.template entity in
  return (MEntity.Data.description tmpl data) 
