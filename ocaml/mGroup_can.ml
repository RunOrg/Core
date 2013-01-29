(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = MGroup_core

include HEntity.Can(struct

  type core = E.t
  type 'a id = 'a IGroup.id

  let deleted e = e.E.del <> None
  let iid     e = e.E.iid
  let admin   e = [ `Admin ; e.E.admins ]

  let view e = 
    match e.E.vision with 
      | `Public  -> [ `Contact ]
      | `Normal  -> [ `Token   ]
      | `Private -> `Groups (`Any,[ e.E.gid ]) :: admin e
	
  let id_view  id = IGroup.Assert.view id
  let id_admin id = IGroup.Assert.admin id 
  let decay    id = IGroup.decay id 

  let public    e = not (deleted e) && e.E.vision = `Public 

end)

let member_access t = 
  `Groups (`Validated,[ (data t).E.gid ]) :: admin_access t
