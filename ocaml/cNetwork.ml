(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render ?tag title list req res = 

  let uid = CSession.get req in

  let! stats = ohm $ MInstance.Profile.tag_stats () in
  let tags = List.map (fun (tag,count) -> (object
    method tag   = CTag.prepare tag
    method count = count
  end)) stats in 

  let! list = ohm $ Run.list_map begin fun profile -> 
    let! pic = ohm $ CPicture.small_opt (profile # pic) in
    return (object
      method url  = Action.url UrlClient.website (profile # key) ()
      method pic  = pic 
      method name = profile # name
      method tags = List.map CTag.prepare (profile # tags)
    end)
  end list in

  let html = Asset_Network_List.render (object
    method navbar = (uid,None)
    method tags   = tags
    method tag    = BatOption.map (fun (tag,home) -> (object
      method tag  = tag
      method home = home
    end)) tag
    method list   = list 
  end) in

  CPageLayout.core title html res

let () = UrlNetwork.def_root begin fun req res -> 

  let! list, next = ohm $ MInstance.Profile.all ~count:20 () in
  let  title      = `Network_Title in

  render title list req res

end

let () = UrlNetwork.def_tag begin fun req res -> 

  let  tag        = req # args in
  let  home       = Action.url UrlNetwork.root () () in
  let! list, next = ohm $ MInstance.Profile.by_tag ~count:20 tag in
  let  title      = `Network_Title_WithTag tag in

  render ~tag:(tag,home) title list req res

end
    
let () = UrlNetwork.def_news begin fun req res -> 

  let uid = CSession.get req in

  let start = req # args in

  let! broadcasts, next = ohm $ MBroadcast.all_latest ?start 15 in
  let! list = ohm $ CBroadcast.render_list broadcasts in

  let! more = ohm begin match next with 
    | None -> return $ Html.str "" 
    | Some time -> let url = Action.url (req # self) () (Some time) in
		   Asset_Broadcast_More.render url
  end in 
  
  let news = (Html.concat [ list ; more ]) in

  let html = Asset_Network_News.render (object
    method news = news
    method navbar = (uid, None)
  end) in 

  CPageLayout.core `Network_News_Title html res

end
