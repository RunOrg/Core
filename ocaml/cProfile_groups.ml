(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let status_tag gender = function
  | `Member   -> `GroupMember gender
  | `Unpaid   -> `Unpaid gender
  | `Pending  -> `Pending gender
  | `Invited  -> `Invited gender
  | _         -> `Declined gender
  
let body access aid me render = 

  O.Box.fill $ O.decay begin 

    let  actor = access # actor in 
    let! list = ohm $ MEntity.All.get_by_kind actor `Group in
    
    let! groups = ohm $ Run.list_filter begin fun entity -> 
      
      let! () = true_or (return None) (not (MEntity.Get.draft entity)) in
      
      let! name   = ohm $ CEntityUtil.name entity in
      
      let  gid    = MEntity.Get.group entity in 
      
      if me then 
	
	let! status = ohm_req_or (return None) begin 	
	  let! status = ohm $ MMembership.status actor gid in
	  return (if status <> `NotMember && status <> `Declined then Some status else None) 
	end in            
	
	let gender = None in 
	
	return $ Some (object
	  method url    = Action.url UrlClient.Members.home (access # instance # key) 
	    [ IEntity.to_string (MEntity.Get.id entity) ]
	  method name   = name
	  method status = status_tag gender status
	end)
	  
      else
	
	let! group = ohm_req_or (return None) $ MGroup.try_get actor gid in 
	let! group = ohm_req_or (return None) $ MGroup.Can.list group in 
	
	let! mid = ohm $ MMembership.as_viewer (MGroup.Get.id group) aid in
	let! mbr = ohm_req_or (return None) $ MMembership.get mid in 
	
	let! status = req_or (return None) 
	  MMembership.(if mbr.status <> `NotMember && mbr.status <> `Declined then Some mbr.status else None) 
	in
	
	let gender = None in
	
	let! url = ohm begin 
	  let eid = IEntity.to_string (MEntity.Get.id entity) in
	  let! admin = ohm $ MEntity.Can.admin entity in 
	  if admin = None then 
	    return (Action.url UrlClient.Members.home (access # instance # key) [ eid ])
	  else
	    return (Action.url UrlClient.Members.join (access # instance # key) [ eid ; IAvatar.to_string aid ])
	end in
	
	return $ Some (object
	  method url    = url 
	  method name   = name
	  method status = status_tag gender status
	end)
	  
    end list in 
    
    render (Asset_Profile_Groups.render groups)

  end 
