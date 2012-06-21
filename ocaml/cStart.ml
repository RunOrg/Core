(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlStart.def_home begin fun req res -> 

  let login = 
    let url = UrlLogin.save_url (BatString.nsplit req # path "/") in
    return $ Action.redirect (Action.url UrlLogin.login () url) res
  in

  let! cuid = req_or login $ CSession.get req in

  let vertical = BatOption.default `Simple (req # args) in

  let html = Asset_Start_Page.render (object
    method navbar     = (Some cuid,None)
    method back       = "/" 
    method categories = PreConfig_Vertical.Catalog.list
    method url        = Action.url UrlStart.create () ()
    method upload     = Action.url UrlUpload.Core.root () ()  
    method free       = Action.url UrlStart.free () ()
    method init       = PreConfig_Vertical.Catalog.init vertical
    method pics       = Action.url UrlUpload.Core.find () () 
  end) in

  CPageLayout.core `Start_Title html res 

end

let () = UrlStart.def_free begin fun req res -> 

  let name = BatOption.default "test" (req # get "name") in

  let! key = ohm $ MInstance.free_name name in 

  return $ Action.json [ "key", Json.String key ] res

end

module FormFmt = Fmt.Make(struct
  type json t = <
    desc : string option ;
    name : string ;
    key  : string ;
    vertical : string ;
    pic : string option ;
  >
end)

let () = UrlStart.def_create begin fun req res -> 

  let  fail = return res in

  let! cuid = req_or fail $ CSession.get req in

  let! json = req_or fail (Action.Convenience.get_json req) in
  let! post = req_or fail (FormFmt.of_json_safe json) in

  let! vertical = req_or fail $ PreConfig_Vertical.Catalog.vertical (post # vertical) in

  let! key = ohm $ MInstance.free_name (post # key) in 

  let! pic = ohm begin 
    let! pic = req_or (return None) (post # pic) in
    let! fid, _ = req_or (return None) (try Some (BatString.split pic "/") with _ -> None) in
    MFile.own_pic cuid (IFile.of_string fid) 
  end in

  let! iid = ohm $ MInstance.create
    ~pic
    ~who:cuid
    ~key
    ~name:(post # name)
    ~address:None
    ~desc:(post # desc)
    ~site:None
    ~contact:None
    ~vertical
  in

  let url = Action.url UrlClient.Home.home key [] in
  
  return $ Action.javascript (Js.redirect ~url ()) res

end
