(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let white req res = 
  CPageLayout.core `EMPTY (return ignore) res 

let () = UrlUpload.Core.def_cancel white
let () = UrlUpload.Core.def_ok     white

let () = UrlUpload.Core.def_root begin fun req res -> 

  let! cuid = req_or (white req res) $ CSession.get req in
    
  let! fid = ohm_req_or (white req res) $ MFile.Upload.prepare_pic ~cuid in
  
  let proof = IFile.Deduce.make_getPic_token cuid (IFile.Deduce.get_pic fid) in 

  let redirect = 
    Action.url UrlUpload.Core.ok () (IFile.decay fid, proof) 
  in

  let html = 
    Asset_Upload_Form.render 
      (ConfigS3.upload_form 
	 (MFile.Upload.configure fid redirect)
	 (fun inner -> 
	   Asset_Upload_Form_Inner.render (object
	     method cancel = Action.url UrlUpload.Core.cancel () ()
	     method inner  = inner
	   end))
      )
  in

  CPageLayout.core `EMPTY html res

end

let () = UrlUpload.Core.def_find begin fun req res -> 

  return res

end 
