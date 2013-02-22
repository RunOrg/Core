(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common 

let render_files ?start ~count access repo self = 

  let! time = ohmctx (#time) in

  let  rid = MRepository.Get.id repo in 
  let! files, next = ohm $ MDocument.All.in_repository ~actor:(access # actor) ?start ~count rid in

  let  more = BatOption.map (fun next -> OhmBox.reaction_endpoint self next, Json.Null) next in 

  let! items = ohm $ Run.list_map begin fun file -> 
    let! author = ohm $ O.decay (CAvatar.mini_profile (snd (file # update))) in
    return (object
      method name    = file # name
      method version = file # version 
      method time    = (time, fst (file # update))
      method author  = author
      method url     = Action.url Url.file (access # instance # key)
	[ IDocument.to_string (MDocument.Get.id (file # doc)) ]
     end)
  end files in

  Asset_DMS_Repository_Inner.render (object
    method items = items
    method more  = more
  end) 


let () = CClient.define Url.def_see begin fun access ->
  
  let  e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! rid = O.Box.parse IRepository.seg in

  let! repo = ohm_req_or e404 $ MRepository.view ~actor rid in

  let! more = O.Box.react Fmt.Float.fmt begin fun start _ self res -> 
    let! html = ohm $ render_files ~start ~count:8 access repo self in
    return $ Action.json [ "more", Html.to_json html ] res
  end in 

  let! upload = ohm begin 
    let! rid = ohm_req_or (return None) (MRepository.Can.upload repo) in
    return (Some (Action.url Url.upload (access # instance # key) 
		    [ IRepository.to_string rid ]))
  end in

  O.Box.fill begin 
    Asset_DMS_Repository.render (object
      method name   = MRepository.Get.name repo 
      method upload = upload
      method list   = render_files ~count:0 access repo more 
    end)
  end 

end 
