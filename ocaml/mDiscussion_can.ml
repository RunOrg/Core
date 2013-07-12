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
  let admin   e = 
    (* Do not show private messages to all admins... *)
    if e.D.gids = [] then return (MAvatarStream.avatars [ e.D.crea ]) 
    else return MAvatarStream.(admins + avatars [ e.D.crea ])
  let view    e = let! admin = ohm (admin e) in 
		  return MAvatarStream.(groups `Member e.D.gids + avatars e.D.aids + admin)
  let public  e = false

  let id_view  id = IDiscussion.Assert.view id
  let id_admin id = IDiscussion.Assert.admin id 
  let decay    id = IDiscussion.decay id

end)

