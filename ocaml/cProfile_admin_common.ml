(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Parents = CProfile_admin_parents

let define d box = CClient.define d begin fun access -> 
  let forbidden = O.Box.fill (Asset_Profile_Forbidden.render ()) in

  let! aid = O.Box.parse IAvatar.seg in
  let! pid = ohm $ O.decay (MAvatar.profile aid) in

  let! name = ohm $ O.decay (CAvatar.name aid) in 

  (* Administrators can edit profiles *)  
  let! admin = req_or forbidden (CAccess.admin access) in
  let  pid   = IProfile.Assert.admin in

  let  key = access # instance # key in
  let  parents = Parents.parents name key aid in 

  box parents pid access

end
