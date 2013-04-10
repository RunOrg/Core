(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render_list list = 

  let! list = ohm $ Run.list_filter begin fun b -> 
    let! instance = ohm_req_or (return None) $ MInstance.get (b # from) in
    let  server = instance # key in
    let! pic = ohm $ CPicture.small (instance # pic) in     
    let! now = ohmctx (#time) in

    let  title = match b # content with 
      | `Post p -> p # title
      | `RSS  r -> r # title
    in
    let! title = ohm begin 
      if BatString.strip title <> "" then return title else
	AdLib.get `Broadcast_Untitled
    end in 

    return $ Some (object
      method title = title
      method html  = match b # content with 
	| `Post p -> MRich.OrText.to_html (p # body)
	| `RSS  r -> Html.str (OhmSanitizeHtml.html (r # body))
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
