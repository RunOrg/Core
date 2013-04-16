(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocTask_common

module Edit = DMS_CDocTask_edit
module Notify = DMS_CDocTask_notify

let () = CClient.define Url.Task.def_create begin fun access ->

  let  e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! rid = O.Box.parse IRepository.seg in
  let! did = O.Box.parse IDocument.seg in 

  let! doc = ohm_req_or e404 $ MDocument.view ~actor did in
  let  did = MDocument.Get.id doc in

  let processes = PreConfig_Task.DMS.all in

  let! create = O.Box.react Fmt.Unit.fmt begin fun _ json _ res ->
    let! idx = req_or (return res) $ Fmt.Int.of_json_safe json in 
    let! process = req_or (return res) 
      (try Some (List.nth processes idx) with _ -> None) in
    let! dtid = ohm $ MDocTask.createIfMissing ~process ~actor:(access # actor) did in
    let  url = Action.url Url.Task.edit (access # instance # key) 
      [ IRepository.to_string rid ; IDocument.to_string did ; IDocTask.to_string dtid ] in
    return (Action.json [ "url" , Json.String url ] res)
  end in

  O.Box.fill begin 

    let processes = List.map begin fun pid -> (object
      method label = PreConfig_Task.DMS.label pid 
    end) end processes in

    Asset_Admin_Page.render (object
      method parents = [ parent (access # instance # key) rid doc ]
      method here = AdLib.get `DMS_DocTask_Create
      method body = Asset_DMS_CreateTask.render (object
	method processes = processes
	method url = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint create ()) 
      end)
    end)

  end 

end
