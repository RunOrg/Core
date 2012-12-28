(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module D = MDiscussion_core

include HEntity.Can(struct

  type core = D.t
  type 'a id = 'a IDiscussion.id

  let deleted e = e.D.del <> None
  let iid     e = e.D.iid
  let admin   e = [ `Admin ; `List [ e.D.crea ] ] 
  let view    e = `Groups (`Validated,e.D.gids) :: admin e
  let public  e = false

  let id_view  id = IDiscussion.Assert.view id
  let id_admin id = IDiscussion.Assert.admin id 

end)

