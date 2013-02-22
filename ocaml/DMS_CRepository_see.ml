(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module IRepository = DMS_IRepository
module MRepository = DMS_MRepository
module Url = DMS_Url

let () = CClient.define Url.def_see begin fun access ->
  
  let  e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! rid = O.Box.parse IRepository.seg in

  let! repo = ohm_req_or e404 $ MRepository.view ~actor rid in

  O.Box.fill begin 
    Asset_DMS_Repository.render (object
      method name   = MRepository.Get.name repo 
    end)
  end 

end 
