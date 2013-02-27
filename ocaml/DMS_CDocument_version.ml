(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open DMS_CDocument_common 

let () = CClient.define Url.Doc.def_version begin fun access ->

  let back rid did =
    Action.url Url.file (access # instance # key) 
      [ IRepository.to_string rid ; IDocument.to_string did ]
  in

  let noUpload rid did = 
    Asset_DMS_NoUpload.render (back rid did) 
  in

  let  actor = access # actor in 
  let! rid = O.Box.parse IRepository.seg in
  let! did = O.Box.parse IDocument.seg in 

  let  fail = noUpload rid did in
  let  back = back rid did in

  let! peek = O.Box.react IFile.fmt begin fun fid _ _ res -> 
    let! _ = ohm_req_or (return res) $ MDocument.ready fid in
    return (Action.json [ "url", Json.String back ] res)
  end in

  let  iid   = IInstance.Deduce.upload (access # iid) in 
  let  cuid  = MActor.user (access # actor) in 

  O.Box.fill begin 
    let! doc = ohm_req_or fail $ MDocument.admin ~actor did in
    let! fid = ohm_req_or fail $ MDocument.add_version ~self:actor ~iid doc in
    Asset_DMS_Upload.render (object
      method upload = Action.url Url.upform (access # instance # key) 
	(IFile.decay fid, IFile.Deduce.make_putDoc_token cuid fid)
      method back = back  
      method peek = JsCode.Endpoint.to_json 
	(OhmBox.reaction_endpoint peek (IFile.decay fid))
    end)
  end 

end
