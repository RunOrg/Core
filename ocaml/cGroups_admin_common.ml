(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Parents = CGroups_admin_parents

let define d box = CClient.define d begin fun access -> 
  let forbidden = O.Box.fill (Asset_Group_Forbidden.render ()) in

  let! gid = O.Box.parse IGroup.seg in

  let! group = ohm_req_or forbidden $ MGroup.admin ~actor:(access # actor) gid in

  let  gid = MGroup.Get.id group in
  let  key = access # instance # key in
  let! title = ohm $ MGroup.Get.fullname group in 
  
  let parents = Parents.parents title key gid in 

  box parents group access

end
