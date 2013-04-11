(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Parents = CDiscussion_admin_parents

let define d box = CClient.define d begin fun access -> 
  let forbidden = O.Box.fill (Asset_Discussion_Forbidden.render ()) in

  let! did = O.Box.parse IDiscussion.seg in

  let! discn = ohm_req_or forbidden $ MDiscussion.admin ~actor:(access # actor) did in

  let  did = MDiscussion.Get.id discn in 
  let  key = access # instance # key in
  let  title = MDiscussion.Get.title discn in
  
  let parents = Parents.parents title key did in 

  box parents discn access

end
