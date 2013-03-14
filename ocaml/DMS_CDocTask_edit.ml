(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocTask_common

let () = CClient.define Url.Task.def_edit begin fun access ->

  let  e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! rid  = O.Box.parse IRepository.seg in
  let! did  = O.Box.parse IDocument.seg in 
  let! dtid = O.Box.parse IDocTask.seg in

  let! doc  = ohm_req_or e404 $ MDocument.view ~actor did in
  let  did  = MDocument.Get.id doc in

  let! task = ohm_req_or e404 $ MDocTask.getFromDocument dtid did in

  O.Box.fill begin 

    Asset_Admin_Page.render (object
      method parents = [ parent (access # instance # key) rid doc ]
      method here = AdLib.get `DMS_DocTask_Edit
      method body = return (Html.str "")
    end)

  end 

end
