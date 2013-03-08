(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common

module Parents = DMS_CDocument_admin_parents

let define d box = CClient.define d begin fun access -> 
  let forbidden = O.Box.fill (Asset_DMS_Forbidden.render ()) in

  let! rid = O.Box.parse IRepository.seg in
  let! did = O.Box.parse IDocument.seg in 

  let! doc = ohm_req_or forbidden $ MDocument.admin ~actor:(access # actor) did in

  let  did   = MDocument.Get.id doc in 
  let  key   = access # instance # key in
  let  title = MDocument.Get.name doc in 
  
  let parents = Parents.parents title key rid did in 

  box parents rid doc access

end
