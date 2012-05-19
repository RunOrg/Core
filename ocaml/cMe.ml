(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlMe.def_root begin fun req res -> 

  let html = Asset_Me_Page.render (object
    method navbar = (None,None)
  end) in

  let js = Js.initBoxStack ~url:"/me/ajax" () in

  CPageLayout.core ~deeplink:true `Login_Title html 
    (Action.javascript js res)

end
    
