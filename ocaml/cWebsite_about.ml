(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Left      = CWebsite_left

let () = UrlClient.def_about begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in
  
  let main = Asset_Website_About.render (object
    method html = "&nbsp;"
  end) in

  let left = Left.render ~calendar:false cuid key iid in 
  let html = VNavbar.public `About ~cuid ~left ~main instance in

  CPageLayout.core (`Website_About_Title (instance # name)) html res

end

