(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common 

let () = CClient.define Url.def_file begin fun access ->
  
  let  e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! rid = O.Box.parse IRepository.seg in
  let! did = O.Box.parse IDocument.seg in 

  let! doc = ohm_req_or e404 $ MDocument.view ~actor did in

  O.Box.fill begin 
    Asset_DMS_Document.render (object
      method admin = None
      method name  = MDocument.Get.name doc 
    end)
  end 

end 
