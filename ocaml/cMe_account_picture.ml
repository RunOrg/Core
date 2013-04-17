(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents

let () = define UrlMe.Account.def_picture begin fun owid cuid -> 

  let parents = Parents.make owid in 

  O.Box.fill begin

    let! user = ohm $ O.decay (MUser.get (IUser.Deduce.can_view cuid)) in
    let  pic  = BatOption.bind (#picture) user in 
    let  id   = match pic with 
      | None -> "" 
      | Some fid -> IOldFile.to_string (IOldFile.decay fid) ^ "/" ^ IOldFile.Deduce.make_getPic_token cuid fid
    in

    let html = Asset_Upload_Picture.render (object
      method url = JsCode.Endpoint.to_json 
	(JsCode.Endpoint.of_url (Action.url UrlMe.Account.picpost owid ()))
      method upload = Action.url UrlUpload.Core.root owid ()
      method pics = Action.url UrlUpload.Core.find owid ()
      method back = parents # home # url 
      method id = id
    end) in

    Asset_Admin_Page.render (object
      method parents = [ parents # home ; parents # admin ] 
      method here  = parents # picture # title
      method body  = html
    end)

  end
end

let () = UrlMe.Account.def_picpost begin fun req res -> 

  let parents = Parents.make (req # server) in

  let! cuid = req_or (return res) $ CSession.get req in 
  
  let! pic = ohm begin
    let! json = req_or (return None) $ Action.Convenience.get_json req in 
    let! pic = req_or (return None) (try Some (Json.to_string json) with _ -> None) in
    let! fid, _ = req_or (return None) (try Some (BatString.split pic "/") with _ -> None) in
    MOldFile.own_pic cuid (IOldFile.of_string fid) 
  end in

  let! () = ohm $ MUser.set_pic (IUser.Deduce.can_edit cuid) pic in 

  let url = parents # home # url in

  return $ Action.javascript (Js.redirect url ()) res
  
end
