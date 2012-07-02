(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Parents = CEvents_admin_parents

let define d box = CClient.define d begin fun access -> 
  let forbidden = O.Box.fill (Asset_Event_Forbidden.render ()) in

  let! eid = O.Box.parse IEntity.seg in

  let! entity = ohm_req_or forbidden $ O.decay (MEntity.try_get access eid) in
  let! entity = ohm_req_or forbidden $ O.decay (MEntity.Can.admin entity) in

  let  eid = MEntity.Get.id entity in 
  let  key = access # instance # key in
  let! title = ohm $ CEntityUtil.name entity in 
  
  let parents = Parents.parents title key eid in 

  box parents entity access

end
