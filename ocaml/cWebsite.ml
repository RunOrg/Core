(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Account = CMe_account

let () = UrlClient.def_website begin fun req res -> 

  let  cuid = CSession.decay (CSession.check req) in
  let  p404 = C404.render cuid res in

  let  key      = req # server in
  let! iid      = ohm_req_or p404 $ MInstance.by_key key in
  let! instance = ohm_req_or p404 $ MInstance.get iid in

  let! broadcasts, next = ohm $ MBroadcast.latest ~count:5 iid in

  let  main = 

    let! list = ohm $ Run.list_filter begin fun b -> 
      let! instance = ohm_req_or (return None) $ MInstance.get (b # from) in
      let! pic = ohm $ CPicture.small (instance # pic) in     
      let! now = ohmctx (#time) in
      return $ Some (object
	method title = match b # content with 
	  | `Post p -> p # title
	  | `RSS  r -> r # title
	method html  = match b # content with 
	  | `Post p -> p # body
	  | `RSS  r -> OhmSanitizeHtml.html (r # body)
	method from  = instance # name
	method pic   = pic
	method time  = (b # time,now)
      end) 
    end broadcasts in

    Asset_Broadcast_List.render (object
      method list = list
    end)

  in

  let  left = return $ Html.esc "LEFT" in
  let  html = VNavbar.public ~cuid:None ~left ~main instance in

  CPageLayout.core `Me_Title html res

end
   
