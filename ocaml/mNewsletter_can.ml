(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = MNewsletter_core

include HEntity.Can(struct

  type core = E.t
  type 'a id = 'a INewsletter.id

  let deleted e = e.E.del <> None
  let iid     e = e.E.iid
  let admin   e = return MAvatarStream.(admins + avatars [ e.E.crea ])
  let view    e = let! admin = ohm (admin e) in 
		  let  gids  = List.map fst e.E.gids in
		  return MAvatarStream.(groups `Member gids + admin)
  let public  e = false

  let id_view  id = INewsletter.Assert.view id
  let id_admin id = INewsletter.Assert.admin id 
  let decay    id = INewsletter.decay id

end)

