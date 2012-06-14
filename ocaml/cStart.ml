(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlStart.def_home begin fun req res -> 

  let login = 
    let url = UrlLogin.save_url (BatString.nsplit req # path "/") in
    return $ Action.redirect (Action.url UrlLogin.login () url) res
  in
  
  let! cuid = req_or login begin 
    match CSession.check req with 
      | `None     -> None
      | `Old cuid -> Some (ICurrentUser.decay cuid) 
      | `New cuid -> Some (ICurrentUser.decay cuid)
  end in

  let vertical = BatOption.default `Simple (req # args) in

  let html = Asset_Start_Page.render (object
    method navbar     = (Some cuid,None)
    method back       = "/" 
    method categories = PreConfig_Vertical.Catalog.list
    method url        = "/"
    method upload     = Action.url UrlUpload.Core.root () ()  
    method free       = Action.url UrlStart.free () ()
    method init       = PreConfig_Vertical.Catalog.init vertical
  end) in

  CPageLayout.core `Start_Title html res 

end

let () = UrlStart.def_free begin fun req res -> 

  let name = BatOption.default "test" (req # get "name") in

  let! key = ohm $ MInstance.free_name name in 

  return $ Action.json [ "key", Json.String key ] res

end
