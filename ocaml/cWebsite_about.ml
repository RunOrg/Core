(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Left      = CWebsite_left

let () = UrlClient.def_about begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in
  
  let! profile = ohm_req_or (C404.render cuid res) $ MInstance.Profile.get iid in  

  let! status = ohm $ Run.opt_map (MAvatar.status iid) cuid in 

  let actions = if status = Some `Admin then
      [ object
	method green = false
	method url   = Action.url UrlClient.Website.about key []
	method label = AdLib.write `Website_About_Edit
      end ] 
    else []
  in

  let tags = List.map CTag.prepare (profile # tags) in

  let! map = ohm begin
    let! addr = req_or (return None) (profile # address) in 
    let  akey = Netencoding.Url.encode addr in
    return $ Some (object (self)
      method address = addr
      method enlarge = "http://maps.google.fr/maps?f=q&hl=fr&q="^akey
      method iframe  = self # enlarge ^ "&hnear="^akey^"&iwloc=N&t=m&output=embed&ie=UTF8"
    end)
  end in 

  let main = Asset_Website_About.render (object
    method html     = BatOption.map MRich.OrText.to_html profile # desc 
    method tags     = tags
    method site     = profile # site
    method twitter  = profile # twitter
    method facebook = profile # facebook
    method map      = map
    method phone    = profile # phone
  end) in

  let main = Asset_Website_Page.render (object
    method actions = actions
    method content = main
  end) in

  let left = Left.render cuid key iid in 
  let html = VNavbar.public `About ~cuid ~left ~main instance in

  CPageLayout.core (`Website_About_Title (instance # name)) html res

end

