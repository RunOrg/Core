(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Cancelling an upload ------------------------------------------------------------------------------------- *)

let white req res = 
  CPageLayout.core `EMPTY (return ignore) res 

let () = UrlUpload.Core.def_cancel white
let () = UrlUpload.Client.def_cancel white

(* Confirming an upload ------------------------------------------------------------------------------------- *)

let confirm req res = 

  let white = white req res in 
  let fid, proof = req # args in

  let! cuid  = req_or white $ CSession.get req in
  let! fid   = req_or white $ IFile.Deduce.from_getPic_token cuid fid proof in

  let! () = ohm $ MFile.Upload.confirm_pic fid in 

  white

let () = UrlUpload.Core.def_ok confirm
let () = UrlUpload.Client.def_ok confirm

(* Preparing an upload ------------------------------------------------------------------------------------- *) 

let form cuid fid cancel ok res = 

  let proof = IFile.Deduce.make_getPic_token cuid (IFile.Deduce.get_pic fid) in 
  let redirect = ok (IFile.decay fid, proof) in

  let html = 
    Asset_Upload_Form.render 
      (ConfigS3.upload_form 
	 (MFile.Upload.configure fid redirect)
	 (fun inner -> 
	   Asset_Upload_Form_Inner.render (object
	     method cancel = cancel 
	     method inner  = inner
	   end))
      )
  in

  CPageLayout.core `EMPTY html res

let () = UrlUpload.Core.def_root begin fun req res -> 

  let! cuid = req_or (white req res) $ CSession.get req in
    
  let! fid = ohm_req_or (white req res) $ MFile.Upload.prepare_pic ~cuid in
  
  form cuid fid 
    (Action.url UrlUpload.Core.cancel () ())
    (Action.url UrlUpload.Core.ok ())
    res

end

let () = UrlUpload.Client.def_root $ CClient.action begin fun access req res -> 

  let cuid = IIsIn.user access # isin in
  let iid  = IInstance.Deduce.upload (access # iid) in
    
  let! fid = ohm_req_or (white req res) $ MFile.Upload.prepare_client_pic ~iid ~cuid in
  
  form cuid fid 
    (Action.url UrlUpload.Client.cancel (req # server) ())
    (Action.url UrlUpload.Client.ok (req # server))
    res

end


(* Find a picture based on its identifier (and key) --------------------------------------------------------- *)

let find req res = 
  let fail = return res in

  let! cuid  = req_or fail $ CSession.get req in

  let! id    = req_or fail $ BatOption.map IFile.of_string (req # get "id") in
  let! proof = req_or fail $ req # get "proof" in
  let! fid   = req_or fail $ IFile.Deduce.from_getPic_token cuid id proof in

  let! small = ohm_req_or fail $ MFile.Url.get fid `Small in
  let! large = ohm_req_or fail $ MFile.Url.get fid `Large in

  return $ Action.json [
    "small", Json.String small ;
    "large", Json.String large ;
  ] res

let () = UrlUpload.Core.def_find find
let () = UrlUpload.Client.def_find find
