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

let pic_small_opt entity = 
  CPicture.small_opt (MEntity.Get.picture entity)

let desc entity = 
  let  eid  = MEntity.Get.id entity in
  let! data = ohm_req_or (return None) $ MEntity.Data.get eid in 
  let  tmpl = MEntity.Get.template entity in
  return (MEntity.Data.description tmpl data) 

let data entity = 
  let  eid  = MEntity.Get.id entity in
  let! data = ohm_req_or (return []) $ MEntity.Data.get eid in 
  return $ MEntity.Data.data data

let public_forum entity = 

  (* The forum must be seen by everyone *)
  match MEntity.Get.real_access entity with 
    | `Private -> false
    | `Normal | `Public -> 

      (* The wall itself must be seen by any entity viewers *)
      let config = MEntity.Get.config entity in 
      let tmpl   = MEntity.Get.template entity in
      match MEntityConfig.wall tmpl config with 
	| Some c when c # read = `Viewers -> true
	| _ -> false

let private_forum entity = 
  not (public_forum entity) && MEntity.Get.kind entity = `Forum 
