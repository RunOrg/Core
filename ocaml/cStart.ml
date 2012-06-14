(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlStart.def_home begin fun req res -> 

  let uid = 
    match CSession.check req with 
      | `None     -> None
      | `Old cuid -> Some (ICurrentUser.decay cuid) 
      | `New cuid -> Some (ICurrentUser.decay cuid)
  in

  let html = Asset_Start_Page.render (object
    method navbar     = (uid,None)
    method back       = "" 
    method categories = PreConfig_Vertical.Catalog.list
    method url        = "" 
    method free       = Action.url UrlStart.free () ()
  end) in

  CPageLayout.core `Start_Title html res 

end

let () = UrlStart.def_free begin fun req res -> 

  return $ Action.json [ "key", Json.String "foobar" ] res

end
