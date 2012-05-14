(* © 2012 Runorg *)

open Ohm
open Ohm.Universal
open BatPervasives

let reverse iid access = 

  let of_entity = MEntity.access () in 

  let by_status = MAvatar.by_status (IInstance.Deduce.see_contacts iid) in

  let by_group gid state= 
    let! group = ohm_req_or (return []) $ MGroup.naked_get gid in

    (* We need to make sure that we're accessing the right instance *)
    if MGroup.Get.instance group <> IInstance.decay iid then return [] else
      (* We are allowed to access anything the entity needs to get accessors *)
      let gid = IGroup.Assert.list gid in 
      let! list = ohm $ MMembership.InGroup.all gid state in
      return $ List.map snd list
  in

  let by_message mid = 
    let! avatars, groups = ohm $ MMessage.get_participants_forced iid mid in
    let! in_groups       = ohm $ Run.list_map (fun (g,s) -> by_group g s) groups in
    return $ List.concat (avatars :: in_groups)
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
    | `Entity (e,a) -> let! access = ohm $ of_entity e a in aux access
    | `Message m -> by_message m 
  in

  let! list = ohm $ Run.list_map aux access in
  
  return $ BatList.sort_unique compare (List.concat list)
