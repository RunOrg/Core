(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render_list server list = 

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
      method url_asso = Action.url UrlClient.website server ()
      method url_article = UrlClient.article_url server b  
    end) 
  end list in
  
  Asset_Broadcast_List.render (object
    method list = list
  end)

let render_page iid server start = 
  let! broadcasts, next = ohm $ MBroadcast.latest ?start ~count:5 iid in
  let! list = ohm $ render_list server broadcasts in 
  let! more = ohm begin match next with 
    | None -> return $ Html.str "" 
    | Some time -> let url = Action.url UrlClient.articles server time in
		   Asset_Broadcast_More.render url
  end in 
  return (Html.concat [ list ; more ]) 
