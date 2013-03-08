(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common

module Parents = DMS_CRepository_admin_parents

let define d box = CClient.define d begin fun access -> 
  let forbidden = O.Box.fill (Asset_DMS_Forbidden.render ()) in

  let! rid = O.Box.parse IRepository.seg in

  let! repo = ohm_req_or forbidden $ MRepository.admin ~actor:(access # actor) rid in

  let  rid   = MRepository.Get.id repo in 
  let  key   = access # instance # key in
  let  title = MRepository.Get.name repo in 
  
  let parents = Parents.parents title key rid in 

  box parents repo access

end
