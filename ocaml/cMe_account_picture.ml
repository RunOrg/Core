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

    let html = Asset_MeAccount_Picture.render (object
      method url = Json.Null 
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
