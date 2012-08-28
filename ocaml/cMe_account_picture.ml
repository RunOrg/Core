(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents

let () = define UrlMe.Account.def_picture begin fun cuid -> 

  O.Box.fill begin

    let! user = ohm $ O.decay (MUser.get (IUser.Deduce.can_view cuid)) in
    let  pic  = BatOption.bind (#picture) user in 
    let  id   = match pic with 
      | None -> "" 
      | Some fid -> IFile.to_string (IFile.decay fid) ^ "/" ^ IFile.Deduce.make_getPic_token cuid fid
    in

    let html = Asset_Upload_Picture.render (object
      method url = JsCode.Endpoint.to_json 
	(JsCode.Endpoint.of_url (Action.url UrlMe.Account.picpost () ()))
      method upload = Action.url UrlUpload.Core.root () ()
      method pics = Action.url UrlUpload.Core.find () ()
      method back = Parents.home # url 
      method id = id
    end) in

    Asset_Admin_Page.render (object
      method parents = [ Parents.home ; Parents.admin ] 
      method here  = Parents.picture # title
      method body  = html
    end)

  end
end

let () = UrlMe.Account.def_picpost begin fun req res -> 

  let! cuid = req_or (return res) $ CSession.get req in 
  
  let! pic = ohm begin
    let! json = req_or (return None) $ Action.Convenience.get_json req in 
    let! pic = req_or (return None) (try Some (Json.to_string json) with _ -> None) in
    let! fid, _ = req_or (return None) (try Some (BatString.split pic "/") with _ -> None) in
    MFile.own_pic cuid (IFile.of_string fid) 
  end in

  let! () = ohm $ MUser.set_pic (IUser.Deduce.can_edit cuid) pic in 

  let url = Parents.home # url in

  return $ Action.javascript (Js.redirect url ()) res
  
end
