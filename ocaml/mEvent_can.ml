(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = MEvent_core

type 'relation t = {
  eid   : 'relation IEvent.id ;
  data  : E.t ;
  actor : [`IsToken] MActor.t option ;
}

let valid ?actor data = 
  data.E.del = None && begin
    match actor with 
      | None -> true
      | Some actor -> IInstance.decay (MActor.instance actor) = data.E.iid 
  end

let make eid ?actor data = if valid ?actor data then Some {
  eid ;
  data ;
  actor = BatOption.bind MActor.member actor ;
} else None
  
let admin_access t = 
  [ `Admin ; t.data.E.admins ]

let member_access t = 
  if t.data.E.draft then admin_access t else
    `Groups (`Validated,[ t.data.E.gid ]) :: admin_access t

let view_access t = 
  if t.data.E.draft then admin_access t else
    match t.data.E.vision with 
      | `Public  -> [ `Contact ]
      | `Normal  -> [ `Token ]
      | `Private -> member_access t

let id t = t.eid

let data t = t.data

let view t = 
  O.decay begin 
    let t' = { eid = IEvent.Assert.view t.eid ; data = t.data ; actor = t.actor } in   
    if t.data.E.draft then 
      match t.actor with
	| None       -> return None
	| Some actor -> let! ok = ohm $ MAccess.test actor (admin_access t) in
			if ok then return (Some t') else return None
    else
      match t.data.E.vision with 
	| `Public  -> return (Some t')
	| `Normal  -> if t.actor <> None then return (Some t') else return None
	| `Private -> match t.actor with 
	    | None       -> return None
	    | Some actor -> let! ok = ohm $ MAccess.test actor (member_access t) in
			    if ok then return (Some t') else return None
  end
    
let admin t = 
  O.decay begin
    let t' = { eid = IEvent.Assert.admin t.eid ; data = t.data ; actor = t.actor } in
    match t.actor with 
      | None       -> return None
      | Some actor -> let! ok = ohm $ MAccess.test actor (admin_access t) in
		      if ok then return (Some t') else return None
  end
