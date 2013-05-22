(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = DMS_MRepository_core

include HEntity.Can(struct

  type core = E.t
  type 'a id = 'a DMS_IRepository.id

  let deleted e = e.E.del <> None
  let iid     e = e.E.iid
  let admin   e = return (MDelegation.stream e.E.admins)

  let view e = 
    match e.E.vision with 
      | `Normal        -> return MAvatarStream.everyone
      | `Private asids -> let! admin = ohm (admin e) in return MAvatarStream.(groups `Member asids + admin)
	
  let id_view  id = DMS_IRepository.Assert.view id
  let id_admin id = DMS_IRepository.Assert.admin id 
  let decay    id = DMS_IRepository.decay id 

  let public _ = false

end)

let upload t = 
  let! allowed = ohm begin match (data t).E.upload with 
    | `Viewers   -> return true
    | `List aids -> let! admin = ohm (admin_access t) in test t MAvatarStream.(avatars aids + admin)
  end in 
  if allowed then return (Some (DMS_IRepository.Assert.upload (id t)))
  else return None
		    
let remove t = 
  let! allowed = ohm begin match (data t).E.remove with 
    | `Free -> return true
    | `Restricted -> let! admin = ohm (admin_access t) in test t admin
  end in 
  if allowed then return (Some (DMS_IRepository.Assert.remove (id t)))
  else return None

let details_access t = 
  match (data t).E.detail with 
    | `Public  -> view_access t
    | `Private -> admin_access t 

