(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Left      = CWebsite_left

let () = UrlClient.def_about begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in
  
  let! profile = ohm_req_or (C404.render cuid res) $ MInstance.Profile.get iid in  

  let tags = List.map (fun tag -> (object
    method url  = "" 
    method text = tag
  end)) (profile # tags) in

  let main = Asset_Website_About.render (object
    method html = None (* profile # desc *)
    method tags = tags
  end) in

  let left = Left.render ~calendar:false cuid key iid in 
  let html = VNavbar.public `About ~cuid ~left ~main instance in

  CPageLayout.core (`Website_About_Title (instance # name)) html res

end

