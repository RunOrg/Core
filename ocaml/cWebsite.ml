(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Website   = CWebsite_admin
module About     = CWebsite_about
module Article   = CWebsite_article
module Left      = CWebsite_left
module Subscribe = CWebsite_subscribe
module Calendar  = CWebsite_calendar

let page actions content = 
  Asset_Website_Page.render (object
    method actions = actions
    method content = content
  end)

let () = UrlClient.def_website begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in

  let! status = ohm $ Run.opt_map (MAvatar.status iid) cuid in 

  let actions = if status = Some `Admin then
      [ object
	method green = true
	method url   = Action.url UrlClient.Website.write key []
	method label = AdLib.write `Website_Article_New
      end ] 
    else []
  in

  let main = page actions (Article.render_page iid key None) in
  let left = Left.render cuid key iid in 
  let html = VNavbar.public `Home ~cuid ~left ~main instance in

  CPageLayout.core (`Website_Title (instance # name)) html res

end

let () = UrlClient.def_articles begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in

  let main = page [] (Article.render_page iid key (Some (req # args))) in
  let left = Left.render cuid key iid in 
  let html = VNavbar.public `Home ~cuid ~left ~main instance in

  CPageLayout.core (`Website_Title (instance # name)) html res

end
   
let () = UrlClient.def_article begin fun req res -> 

  let! cuid, key, iid, instance = CClient.extract req res in

  let  bid, str  = req # args in
  let! broadcast = ohm_req_or (C404.render cuid res) $ MBroadcast.get bid in

  let! status = ohm $ Run.opt_map (MAvatar.status iid) cuid in 

  let actions = if status = Some `Admin then
      [ object
	method green = false
	method url   = Action.url UrlClient.Website.rewrite key [ IBroadcast.to_string bid ]  
	method label = AdLib.write `Website_Article_Edit
      end ] 
    else []
  in

  let canonical_url = (UrlClient.article_url key broadcast)  in

  let! () = true_or (return (Action.redirect canonical_url res))
    (str = Some (UrlClient.article_url_key broadcast)) in

  let main = page actions (CBroadcast.render_list [broadcast]) in
  let left = Left.render cuid key iid in 
  let html = VNavbar.public `Home ~cuid ~left ~main instance in

  let title = match broadcast # content with 
    | `Post p -> p # title
    | `RSS  r -> r # title
  in 

  CPageLayout.core (`Website_Article_Title (instance # name, title)) html res

end
