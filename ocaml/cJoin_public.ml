(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlClient.def_join begin fun req res ->

  let! cuid, key, iid, instance = CClient.extract req res in

  let main = Asset_Join_PublicNone.render (AdLib.get `Join_PublicNone_Title) in
  let left = CWebsite. Left.render cuid key iid in 
  let html = VNavbar.public `About ~cuid ~left ~main instance in 

  CPageLayout.core (`Join_Public_Title (instance # name)) html res

end
