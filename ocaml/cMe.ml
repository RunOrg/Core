(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlMe.def_root begin fun req res -> 

  let url = Action.url UrlMe.ajax () [] in
  let default = "/account" in

  let html = Asset_Me_Page.render (object
    method navbar = (None,None)
    method box    = OhmBox.render ~url ~default
  end) in

  CPageLayout.core ~deeplink:true `Me_Title html res

end
    
let () = UrlMe.def_ajax begin fun req res -> 

  let body = O.Box.fill (Asset_Me_PageNotFound.render ()) in
  O.Box.response O.BoxCtx.make body req res 

end
