(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = MEvent_core

include HEntity.Can(struct

  type core = E.t
  type 'a id = 'a IEvent.id

  let deleted e = e.E.del <> None
  let iid     e = e.E.iid
  let admin   e = return (MDelegation.stream e.E.admins)

  let view e = 
    if e.E.draft then admin e else 
      match e.E.vision with 
	| `Public  -> return MAvatarStream.everyone
	| `Normal  -> return MAvatarStream.everyone
	| `Private -> let! admin = ohm (admin e) in 
		      return MAvatarStream.(group2 [`Pending;`Invited;`Member;`Declined] e.E.gid + admin) 

  let id_view  id = IEvent.Assert.view id
  let id_admin id = IEvent.Assert.admin id 
  let decay    id = IEvent.decay id 

  let public e = not (deleted e) && e.E.vision = `Public 

end)

let member_access t = 
  if (data t).E.draft then admin_access t else
    let! admin = ohm (admin_access t) in
    return MAvatarStream.(group2 [`Invited;`Member;`Declined] (data t).E.gid + admin) 
