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
  let! adoc = ohm $ MDocument.Can.admin doc in 

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
    end)
  end 

end 
