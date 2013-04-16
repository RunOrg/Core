(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocTask_common

let () = MDocTask.Notify.define begin fun uid u t info ->

  let! access = ohm_req_or (return None) (CAccess.of_notification uid (t # iid)) in
  let! doc  = ohm_req_or (return None) (MDocument.view ~actor:(access # actor) (t # did)) in
  let! task = ohm_req_or (return None) (MDocTask.getFromDocument (t # dtid) (MDocument.Get.id doc)) in

  let  rids = MDocument.Get.repositories doc in 
  let! repo = ohm_req_or (return None) (Run.list_find (MRepository.view ~actor:(access # actor)) rids) in
  let  rid  = MRepository.Get.id repo in

  let  kind = match t # what with 
    | `NewState _ -> `State
    | `SetAssigned aid -> if aid = IAvatar.decay (access # self) then `AssignedSelf else `Assigned 
    | `SetNotified -> `NotifiedSelf
  in

  let! status = req_or (return None) (
    try Some (List.assoc (MDocTask.Get.state task) (MDocTask.Get.states task))
    with Not_found -> None
  ) in

  let key = access # instance # key in 

  let url = Action.url Url.file key [ IRepository.to_string rid ; IDocument.to_string (t # did) ] in

  return (Some (object
      
    method mail = let  name = MDocument.Get.name doc in
		  
		  let  title = `DMS_DocTask_Mail_Title (kind,name) in
		  let  url   = CMail.link (info # id) None (snd key) in

		  let! subtitle = ohm (AdLib.get (MDocTask.Get.label task)) in
		  let  color = if MDocTask.Get.finished task then `Green else `Red in
		  
		  let! author = ohm (CAvatar.mini_profile (t # from)) in
		  
		  let! detail = ohm (VMailBrick.boxTask ~name ~subtitle ~status ~color url) in

		  let  payload = `Action (object
		    method pic = author # pico
		    method name = author # name
		    method action = `DMS_DocTask_Mail_Action kind 
		    method detail = detail
		  end) in

		  let body = [
		    [ `DMS_DocTask_Mail_Body (access # instance # name) ]
		  ] in

		  let buttons = [ VMailBrick.green `DMS_DocTask_Mail_Button url ] in

		  return (title,payload,body,buttons)

    method act _ = return url 

    method item = None

  end))
end
