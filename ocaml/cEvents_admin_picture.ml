(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CEvents_admin_common

let () = define UrlClient.Events.def_picture begin fun parents event access -> 
  
  let! post = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 

    let! pic = ohm begin
      let! pic = req_or (return None) (try Some (Json.to_string json) with _ -> None) in
      let! fid, _ = req_or (return None) (try Some (BatString.split pic "/") with _ -> None) in
      O.decay $ MFile.instance_pic (access # iid) (IFile.of_string fid) 
    end in

    let! () = ohm $ O.decay (MEvent.Set.picture event (access # actor) pic) in

    let url = parents # home # url in 
    
    return $ Action.javascript (Js.redirect url ()) res

  end in

  O.Box.fill begin 

    let cuid = MActor.user (access # actor) in

    let  id   = match MEvent.Get.picture event with 
      | None -> "" 
      | Some fid -> IFile.to_string (IFile.decay fid) ^ "/" ^ IFile.Deduce.make_getPic_token cuid fid
    in

    let html = Asset_Upload_Picture.render (object
      method url = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint post ())
      method upload = Action.url UrlUpload.Client.root (access # instance # key) ()
      method pics = Action.url UrlUpload.Client.find (access # instance # key) ()
      method id = id
    end) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here = parents # picture # title
      method body = html
    end)

  end

end
