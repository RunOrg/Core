(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CRepository_common 

let () = CClient.define Url.def_upload begin fun access ->
  
  let back rid =
    Action.url Url.see (access # instance # key) [ IRepository.to_string rid ]
  in

  let noUpload rid = 
    Asset_DMS_NoUpload.render (back rid) 
  in

  let  actor = access # actor in 
  let! rid   = O.Box.parse IRepository.seg in
  
  let  e404  = O.Box.fill (noUpload rid) in
  
  let! repo  = ohm_req_or e404 $ MRepository.view ~actor rid in
  let! uprid = ohm_req_or e404 $ MRepository.Can.upload repo in 

  let  iid   = IInstance.Deduce.upload (access # iid) in 
  let  cuid  = MActor.user (access # actor) in 

  let! peek = O.Box.react IOldFile.fmt begin fun fid _ _ res -> 
    let! did = ohm_req_or (return res) $ MDocument.ready fid in
    let  url = Action.url Url.file (access # instance # key) 
      [ IRepository.to_string rid ; IDocument.to_string did ] in
    return (Action.json [ "url", Json.String url ] res)
  end in

  O.Box.fill begin 
    let! fid = ohm_req_or (noUpload rid) (MDocument.create ~self:actor ~iid uprid) in
    Asset_DMS_Upload.render (object
      method upload = Action.url Url.upform (access # instance # key) 
	(IOldFile.decay fid, IOldFile.Deduce.make_putDoc_token cuid fid)
      method back = back rid 
      method peek = JsCode.Endpoint.to_json 
	(OhmBox.reaction_endpoint peek (IOldFile.decay fid))
    end)
  end 

end 

let () = Url.def_upform $ CClient.action begin fun access req res ->

  let white = CPageLayout.core None `EMPTY (return ignore) res in 

  let cuid = MActor.user (access # actor) in

  let  (fid : IOldFile.t) , proof = req # args in
  let! fid = req_or white $ IOldFile.Deduce.from_putDoc_token cuid fid proof in

  CUpload.form (snd req # server) fid 
    (Asset_Upload_Form.render)
    (fun inner -> 
      Asset_Upload_Form_Inner.render (object
	method cancel = Action.url UrlUpload.Client.cancel (req # server) () 
	method inner  = inner
      end))
    (IOldFile.Deduce.get_doc |- IOldFile.Deduce.make_getDoc_token cuid) 
    (Action.url UrlUpload.Client.Doc.ok (req # server))
    res

end 
