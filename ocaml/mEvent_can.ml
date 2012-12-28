(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = MEvent_core

include HEntity.Can(struct

  type core = E.t
  type 'a id = 'a IEvent.id

  let deleted e = e.E.del <> None
  let iid     e = e.E.iid
  let admin   e = [ `Admin ; e.E.admins ]

  let view e = 
    if e.E.draft then admin e else 
      match e.E.vision with 
	| `Public  -> [ `Contact ]
	| `Normal  -> [ `Token   ]
	| `Private -> `Groups (`Any,[ e.E.gid ]) :: admin e

  let id_view  id = IEvent.Assert.view id
  let id_admin id = IEvent.Assert.admin id 

  let public e = not (deleted e) && e.E.vision = `Public 

end)

let member_access t = 
  if (data t).E.draft then admin_access t else
    `Groups (`Validated,[ (data t).E.gid ]) :: admin_access t
