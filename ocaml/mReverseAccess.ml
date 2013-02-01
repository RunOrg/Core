(* © 2012 Runorg *)

open Ohm
open Ohm.Universal
open BatPervasives

let inSet_call, inSet = Sig.make (fun list -> Run.map List.concat (Run.list_map identity list)) 

let reverse iid ?start ~count access = 

  let by_status status = 
    let! list, next = ohm $ MAvatar.by_status (IInstance.Deduce.see_contacts iid) ?start ~count status in
    return (match next with None -> list | Some aid -> aid :: list) 
  in
  
  let by_group gid state = 
    let! group = ohm_req_or (return []) $ MAvatarSet.naked_get gid in
    
    (* We need to make sure that we're accessing the right instance *)
    if MAvatarSet.Get.instance group <> IInstance.decay iid then return [] else
      (* We are allowed to access anything the entity needs to get accessors *)
      let  gid = IAvatarSet.Assert.list gid in 
      O.decay (inSet_call (gid,start,count))
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
  
