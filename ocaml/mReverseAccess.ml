(* © 2012 Runorg *)

open Ohm
open Ohm.Universal
open BatPervasives

let reverse iid access = 

  let by_status = MAvatar.by_status (IInstance.Deduce.see_contacts iid) in
  
  let by_group gid state = 
    let! group = ohm_req_or (return []) $ MAvatarSet.naked_get gid in

    (* We need to make sure that we're accessing the right instance *)
    if MAvatarSet.Get.instance group <> IInstance.decay iid then return [] else
      (* We are allowed to access anything the entity needs to get accessors *)
      let gid = IAvatarSet.Assert.list gid in 
      let! list = ohm $ MMembership.InGroup.all gid state in
      return $ List.map snd list
  in

  let rec aux = function 
    | `Nobody -> return []
    | `List l -> return l 
    | `Groups (s,l) -> let! lists = ohm $ Run.list_map (fun gid -> by_group gid s) l in
		       return $ List.concat lists
    | `Union l -> let! lists = ohm $ Run.list_map aux l in
		  return $ List.concat lists
    | `Admin -> by_status `Admin
    | `Token -> by_status `Token
    | `Contact -> by_status `Contact
    | `TokOnly t -> let! inner  = ohm $ aux t in
		    let! tokens = ohm $ by_status `Token in
		    return $ List.filter (flip List.mem tokens) inner
  in

  let! list = ohm $ Run.list_map aux access in
  
  return $ BatList.sort_unique compare (List.concat list)

let reverse_async iid ?start ~count access = 

  (* TODO: only filter the avatars we need *)
  let by_status = MAvatar.by_status (IInstance.Deduce.see_contacts iid) in
  
  let by_group gid state = 
    let! group = ohm_req_or (return []) $ MAvatarSet.naked_get gid in
    
    (* We need to make sure that we're accessing the right instance *)
    if MAvatarSet.Get.instance group <> IInstance.decay iid then return [] else
      (* We are allowed to access anything the entity needs to get accessors *)
      let gid = IAvatarSet.Assert.list gid in 
      (* TODO: only filter the avatars we need *)
      let! list = ohm $ MMembership.InGroup.all gid state in
      return $ List.map snd list
  in
  
  let rec aux = function 
    | `Nobody -> return []
    | `List l -> return l 
    | `Groups (s,l) -> let! lists = ohm $ Run.list_map (fun gid -> by_group gid s) l in
		       return $ List.concat lists
    | `Union l -> let! lists = ohm $ Run.list_map aux l in
		  return $ List.concat lists
    | `Admin -> by_status `Admin
    | `Token -> by_status `Token
    | `Contact -> by_status `Contact
    | `TokOnly t -> let! inner  = ohm $ aux t in
		    let! tokens = ohm $ by_status `Token in
		    return $ List.filter (flip List.mem tokens) inner
  in
  
  let! list = ohm $ O.decay (Run.list_map aux access) in
  
  (* Remove uniques and avatars that occur before the start. If any group-level 
     filtering happened, then there should still be enough elements here to 
     allow for it. 
  *)
  let list = BatList.sort_unique compare (List.concat list) in
  let list = match start with 
    | None -> list
    | Some minaid -> BatList.filter (fun aid -> aid >= minaid) list
  in
  
  return (OhmPaging.slice ~count list)
  
