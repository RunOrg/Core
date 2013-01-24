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
    let! list = ohm $ MGroup.All.visible ~actor (access # iid) in
    
    let! groups = ohm $ Run.list_filter begin fun group -> 
            
      let! name   = ohm $ MGroup.Get.fullname group in 
      
      let  asid    = MGroup.Get.group group in 
      
      if me then 
	
	let! status = ohm_req_or (return None) begin 	
	  let! status = ohm $ MMembership.status actor asid in
	  return (if status <> `NotMember && status <> `Declined then Some status else None) 
	end in            
	
	let gender = None in 
	
	return $ Some (object
	  method url    = Action.url UrlClient.Members.home (access # instance # key) 
	    [ IGroup.to_string (MGroup.Get.id group) ]
	  method name   = name
	  method status = status_tag gender status
	end)
	  
      else
	
	let! avset = ohm_req_or (return None) $ MAvatarSet.try_get actor asid in 
	let! avset = ohm_req_or (return None) $ MAvatarSet.Can.list avset in 
	
	let! mid = ohm $ MMembership.as_viewer (MAvatarSet.Get.id avset) aid in
	let! mbr = ohm_req_or (return None) $ MMembership.get mid in 
	
	let! status = req_or (return None) 
	  MMembership.(if mbr.status <> `NotMember && mbr.status <> `Declined then Some mbr.status else None) 
	in
	
	let gender = None in
	
	let! url = ohm begin 
	  let  gid = IGroup.to_string (MGroup.Get.id group) in
	  let! admin = ohm $ MGroup.Can.admin group in 
	  if admin = None then 
	    return (Action.url UrlClient.Members.home (access # instance # key) [ gid ])
	  else
	    return (Action.url UrlClient.Members.join (access # instance # key) [ gid ; IAvatar.to_string aid ])
	end in
	
	return $ Some (object
	  method url    = url 
	  method name   = name
	  method status = status_tag gender status
	end)
	  
    end list in 
    
    render (Asset_Profile_Groups.render groups)

  end 
