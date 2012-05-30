(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Article = CWebsite_article
module Left    = CWebsite_left

let () = UrlClient.def_website begin fun req res -> 

  let  cuid = CSession.decay (CSession.check req) in
  let  p404 = C404.render cuid res in

  let  key      = req # server in
  let! iid      = ohm_req_or p404 $ MInstance.by_key key in
  let! instance = ohm_req_or p404 $ MInstance.get iid in

  let main = Article.render_page iid key None in
  let left = Left.render iid in 
  let html = VNavbar.public ~cuid ~left ~main instance in

  CPageLayout.core (`Website_Title (instance # name)) html res

end

let () = UrlClient.def_articles begin fun req res -> 

  let  cuid = CSession.decay (CSession.check req) in
  let  p404 = C404.render cuid res in

  let  key      = req # server in
  let! iid      = ohm_req_or p404 $ MInstance.by_key key in
  let! instance = ohm_req_or p404 $ MInstance.get iid in

  let main = Article.render_page iid key (Some (req # args)) in
  let left = Left.render iid in 
  let html = VNavbar.public ~cuid ~left ~main instance in

  CPageLayout.core (`Website_Title (instance # name)) html res

end
   
let () = UrlClient.def_article begin fun req res -> 

  let  cuid = CSession.decay (CSession.check req) in
  let  p404 = C404.render cuid res in

  let  key      = req # server in
  let! iid      = ohm_req_or p404 $ MInstance.by_key key in
  let! instance = ohm_req_or p404 $ MInstance.get iid in

  let  bid, str  = req # args in
  let! broadcast = ohm_req_or p404 $ MBroadcast.get bid in
  
  let canonical_url = (UrlClient.article_url key broadcast)  in

  let! () = true_or (return (Action.redirect canonical_url res))
    (str = Some (UrlClient.article_url_key broadcast)) in

  let main = Article.render_list key [broadcast] in
  let left = Left.render iid in 
  let html = VNavbar.public ~cuid ~left ~main instance in

  let title = match broadcast # content with 
    | `Post p -> p # title
    | `RSS  r -> r # title
  in 

  CPageLayout.core (`Website_Article_Title (instance # name, title)) html res

end
