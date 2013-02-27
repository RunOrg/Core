(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common 

module Version = DMS_CDocument_version
module Admin   = DMS_CDocument_admin

let () = CClient.define Url.def_file begin fun access ->
  
  let  e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let  actor = access # actor in 
  let! rid = O.Box.parse IRepository.seg in
  let! did = O.Box.parse IDocument.seg in 

  let! doc = ohm_req_or e404 $ MDocument.view ~actor did in
  let! adoc = ohm $ MDocument.Can.admin doc in 

  let! current = ohm begin 
    let  v = MDocument.Get.current doc in 
    let! url = ohm_req_or (return None) $ MFile.Url.get (v # file) `File in 
    let! now = ohmctx (#time) in
    let! author = ohm $ O.decay (CAvatar.mini_profile (v # author)) in
    return $ Some (object
      method version  = v # number
      method filename = v # filename
      method icon     = VIcon.of_extension (v # ext)
      method url      = url
      method time     = (v # time, now)
      method author   = author
    end)
  end in 

  O.Box.fill begin 
    Asset_DMS_Document.render (object
      method admin = match adoc with None -> None | Some _ ->  
	Some (object
	  method edit = Action.url Url.Doc.admin (access # instance # key)
	    [ IRepository.to_string rid ; IDocument.to_string did ]
	  method add = Action.url Url.Doc.version (access # instance # key) 
	    [ IRepository.to_string rid ; IDocument.to_string did ]
	end)	
      method name  = MDocument.Get.name doc 
      method current = current
    end)
  end 

end 
