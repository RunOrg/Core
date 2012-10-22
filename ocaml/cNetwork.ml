(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let renderlist ?tag owid list next = 

  let! list = ohm $ Run.list_map begin fun profile -> 
    let! pic = ohm $ CPicture.small_opt (profile # pic) in
    return (object
      method url  = Action.url UrlClient.website (profile # key) ()
      method pic  = pic 
      method name = profile # name
      method tags = List.map (CTag.prepare owid) (profile # tags)
    end)
  end list in

  let next = BatOption.map (fun next -> 
    JsCode.Endpoint.of_url (Action.url UrlNetwork.more owid (next,tag)), Json.Null
  ) next in 
  
  return (object
    method list = list
    method more = next
  end)

let render ?tag title list next req res = 

  let uid = CSession.get req in

  let! stats = ohm $ MInstance.Profile.tag_stats () in
  let tags = List.map (fun (tag,count) -> (object
    method tag   = CTag.prepare (req # server) tag
    method count = count
  end)) stats in 

  let! list = ohm $ renderlist ?tag:(BatOption.map fst tag) (req # server) list next in

  let html = Asset_Network_List.render (object
    method navbar = (req # server,uid,None)
    method tags   = tags
    method tag    = BatOption.map (fun (tag,home) -> (object
      method tag  = tag
      method home = home
    end)) tag
    method list   = list 
  end) in

  CPageLayout.core (req # server) title html res

let () = UrlNetwork.def_root begin fun req res -> 

  let! list, next = ohm $ MInstance.Profile.search ~count:20 [] in
  let  title      = `Network_Title in

  render title list next req res

end

let () = UrlNetwork.def_tag begin fun req res -> 

  let  tag        = req # args in
  let  search     = [`TAG tag] in 
  let  home       = Action.url UrlNetwork.root (req # server) () in
  let! list, next = ohm $ MInstance.Profile.search ~count:20 search in
  let  title      = `Network_Title_WithTag tag in

  render ~tag:(tag,home) title list next req res

end

let () = UrlNetwork.def_more begin fun req res -> 

  let iid, tag = req # args in 

  let search = match tag with None -> [] | Some tag -> [`TAG tag] in

  let! list, next = ohm $ MInstance.Profile.search ~start:iid ~count:20 search in 

  let! list = ohm $ renderlist ?tag (req # server) list next in 
  let! html = ohm $ Asset_Network_List_List.render list in 
  
  return $ Action.json [ "more", Html.to_json html ] res

end
    
let () = UrlNetwork.def_news begin fun req res -> 

  let uid = CSession.get req in

  let start = req # args in

  let! broadcasts, next = ohm $ MBroadcast.all_latest ?start 15 in
  let! list = ohm $ CBroadcast.render_list broadcasts in

  let! more = ohm begin match next with 
    | None -> return $ Html.str "" 
    | Some time -> let url = Action.url (req # self) (req # server) (Some time) in
		   Asset_Broadcast_More.render url
  end in 
  
  let news = (Html.concat [ list ; more ]) in

  let html = Asset_Network_News.render (object
    method news = news
    method navbar = (req # server, uid, None)
  end) in 

  CPageLayout.core (req # server) `Network_News_Title html res

end
