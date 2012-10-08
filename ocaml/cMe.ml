(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Account = CMe_account
module Notify  = CMe_notify
module News    = CMe_news

let () = UrlMe.def_root begin fun req res -> 

  let url = Action.url UrlMe.ajax (req # server) [] in
  let default = "/account" in
  let uid = CSession.get req in

  let html = Asset_Me_Page.render (object
    method navbar = (req # server,uid,None)
    method box    = OhmBox.render ~url ~default
  end) in

  CPageLayout.core ~deeplink:true (req # server) `Me_Title html res

end
    
let () = UrlMe.def_ajax begin fun req res -> 

  notfound req res

end
