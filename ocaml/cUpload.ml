(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Cancelling an upload --------------------------------------------------------------------- *)

let white req res = 
  CPageLayout.core None `EMPTY (return ignore) res 

let () = UrlUpload.Core.def_cancel white
let () = UrlUpload.Client.def_cancel white

(* Confirming an upload --------------------------------------------------------------------- *)

let confirm ?(white=white) prove confirm req res = 

  let white = white req res in 
  let fid, proof = req # args in

  let! cuid  = req_or white $ CSession.get req in
  let! fid   = req_or white $ prove cuid fid proof in

  let! () = ohm $ confirm fid in 

  white

let () = UrlUpload.Core.def_ok 
  (confirm IOldFile.Deduce.from_getPic_token MOldFile.Upload.confirm_pic)

let () = UrlUpload.Client.def_ok 
  (confirm IOldFile.Deduce.from_getPic_token MOldFile.Upload.confirm_pic)

let () = UrlUpload.Client.Doc.def_ok 
  (confirm IOldFile.Deduce.from_getDoc_token MOldFile.Upload.confirm_doc)

let () = UrlUpload.Client.Img.def_confirm
  (confirm ~white:(fun _ res -> return res) 
     IOldFile.Deduce.from_getImg_token MOldFile.Upload.confirm_img)

(* Preparing an upload --------------------------------------------------------------------- *) 

let form owid fid outer inner prove ok res = 
  let proof = prove fid in 
  let redirect = ok (IOldFile.decay fid, proof) in
  let html = outer (ConfigS3.upload_form (MOldFile.Upload.configure fid redirect) inner) in
  CPageLayout.core owid `EMPTY html res

let () = UrlUpload.Core.def_root begin fun req res -> 

  let! cuid = req_or (white req res) $ CSession.get req in
    
  let! fid = ohm_req_or (white req res) $ MOldFile.Upload.prepare_pic ~cuid in
  
  form (req # server) fid 
    (Asset_Upload_Form.render) 
    (fun inner -> 
      Asset_Upload_Form_Inner.render (object
	method cancel = Action.url UrlUpload.Core.cancel (req # server) ()
	method inner  = inner
      end))
    (IOldFile.Deduce.get_pic |- IOldFile.Deduce.make_getPic_token cuid) 
    (Action.url UrlUpload.Core.ok (req # server))
    res

end

let () = UrlUpload.Client.def_root $ CClient.action begin fun access req res -> 

  let cuid = MActor.user (access # actor) in
  let iid  = IInstance.Deduce.upload (access # iid) in
    
  let! fid = ohm_req_or (white req res) $ MOldFile.Upload.prepare_client_pic ~iid ~cuid in
  
  form (snd req # server) fid 
    (Asset_Upload_Form.render) 
    (fun inner -> 
      Asset_Upload_Form_Inner.render (object
	method cancel = Action.url UrlUpload.Client.cancel (req # server) ()
	method inner  = inner
      end))
    (IOldFile.Deduce.get_pic |- IOldFile.Deduce.make_getPic_token cuid) 
    (Action.url UrlUpload.Client.ok (req # server))
    res

end

let () = UrlUpload.Client.Doc.def_root $ CClient.action begin fun access req res -> 

  let cuid = MActor.user (access # actor) in
  let fid  = req # args in 

  let! folder = ohm_req_or (white req res) $ MFolder.try_get (access # actor) fid in 
  let! folder = ohm_req_or (white req res) $ MFolder.Can.write folder in 

  let! _, fid = ohm_req_or (white req res) $ MItem.Create.doc (access # actor) folder in
  
  form (snd req # server) fid 
    (Asset_Upload_DocForm.render) 
    (Asset_Upload_DocForm_Inner.render)
    (IOldFile.Deduce.get_doc |- IOldFile.Deduce.make_getDoc_token cuid) 
    (Action.url UrlUpload.Client.Doc.ok (req # server))
    res

end

let () = UrlUpload.Client.Img.def_prepare $ CClient.action begin fun access req res ->

  let cuid = MActor.user (access # actor) in
  let alid = req # args in 

  let! json = req_or (return res) $ Action.Convenience.get_json req in 
  let! filename = req_or (return res) $ Fmt.String.of_json_safe json in 

  let! album = ohm_req_or (return res) $ MAlbum.try_get (access # actor) alid in 
  let! album = ohm_req_or (return res) $ MAlbum.Can.write album in 

  let! _, fid = ohm_req_or (return res) $ MItem.Create.image (access # actor) album in
  
  let upload_config = MOldFile.Upload.configure fid ~filename ~redirect:"-" in
    
  let upload_url, upload_post = ConfigS3.upload_url upload_config in

  let upload_post = Json.Object (List.map (fun (k,v) -> k, Json.String v) upload_post) in

  let confirm = Action.url UrlUpload.Client.Img.confirm (access # instance # key) 
    (IOldFile.decay fid, IOldFile.Deduce.(get_img fid |> make_getImg_token cuid)) in

  let check = Action.url UrlUpload.Client.Img.check (access # instance # key) 
    (IOldFile.decay fid, IOldFile.Deduce.(get_img fid |> make_getImg_token cuid)) in


  return $ Action.json [ "confirm", Json.String confirm ;
			 "check",   Json.String check ;
			 "upload",  Json.String upload_url ;
			 "post",    upload_post ] res

end


(* Find a picture based on its identifier (and key) ----------------------------------------- *)

let find req res = 
  let  fail = return res in

  let! cuid  = req_or fail $ CSession.get req in

  let! id    = req_or fail $ BatOption.map IOldFile.of_string (req # get "id") in
  let! proof = req_or fail $ req # get "proof" in
  let! fid   = req_or fail $ IOldFile.Deduce.from_getPic_token cuid id proof in

  let! small = ohm_req_or fail $ MOldFile.Url.get fid `Small in
  let! large = ohm_req_or fail $ MOldFile.Url.get fid `Large in

  return $ Action.json [
    "small", Json.String small ;
    "large", Json.String large ;
  ] res

let () = UrlUpload.Core.def_find find
let () = UrlUpload.Client.def_find find

(* Check whether an image has been completely processed *)

let () = UrlUpload.Client.Img.def_check begin fun req res ->

  let  fail = return res in

  let! cuid  = req_or fail $ CSession.get req in

  let  id, proof = req # args in 

  let! fid   = req_or fail $ IOldFile.Deduce.from_getImg_token cuid id proof in

  let! large = ohm_req_or fail $ MOldFile.Url.get fid `Large in

  return $ Action.json [ "ok", Json.Bool true ] res


end
