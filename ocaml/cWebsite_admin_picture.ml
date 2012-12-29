(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CWebsite_admin_common

module Parents = CMe_account_parents

let () = CClient.define_admin UrlClient.Website.def_picture begin fun access -> 

  O.Box.fill begin

    let  cuid = MActor.user (access # actor) in

    let  pic  = access # instance # pic in
    let  id   = match pic with 
      | None -> "" 
      | Some fid -> IFile.to_string (IFile.decay fid) ^ "/" ^ IFile.Deduce.make_getPic_token cuid fid
    in

    let key = access # instance # key in

    let html = Asset_Upload_Picture.render (object
      method url = JsCode.Endpoint.to_json 
	(JsCode.Endpoint.of_url (Action.url UrlClient.Website.picpost key ()))
      method upload = Action.url UrlUpload.Client.root key ()
      method pics = Action.url UrlUpload.Client.find key ()

      method id = id
    end) in

    wrap access `Website_Admin_Picture_Edit html

  end
end

let () = UrlClient.Website.def_picpost begin fun req res -> 

  let! _, key, iid, instance = CClient.extract_ajax req res in 

  let url = Action.url UrlClient.website key () in
  let finish = return $ Action.javascript (Js.redirect url ()) res in

  let! cuid = req_or finish (match CSession.check req with 
    | `Old cuid -> Some cuid 
    |_ -> None
  ) in

  let! access = ohm_req_or finish (CAccess.make cuid iid instance) in 
  let! access = req_or finish (CAccess.admin access) in 

  let! pic = ohm begin
    let! json = req_or (return None) $ Action.Convenience.get_json req in 
    let! pic = req_or (return None) (try Some (Json.to_string json) with _ -> None) in
    let! fid, _ = req_or (return None) (try Some (BatString.split pic "/") with _ -> None) in
    MFile.instance_pic iid (IFile.of_string fid)  
  end in

  let! () = ohm $ MInstance.set_pic (access # iid) pic in 

  finish 
  
end
