(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Parents = CEvents_admin_parents

let define d box = CClient.define d begin fun access -> 
  let forbidden = O.Box.fill (Asset_Event_Forbidden.render ()) in

  let! eid = O.Box.parse IEvent.seg in

  let! event = ohm_req_or forbidden $ MEvent.admin ~access eid in

  let  eid = MEvent.Get.id event in 
  let  key = access # instance # key in
  let! title = ohm $ MEvent.Get.fullname event in 
  
  let parents = Parents.parents title key eid in 

  box parents event access

end
