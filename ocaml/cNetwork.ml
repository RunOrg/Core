(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let renderlist search owid list next = 

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
    JsCode.Endpoint.of_url (Action.url UrlNetwork.more owid (next,search)), Json.Null
  ) next in 
  
  return (object
    method list = list
    method more = next
  end)

let render search title list next req res = 

  let uid = CSession.get req in

  let! stats = ohm $ MInstance.Profile.tag_stats (req # server) in
  let tags = List.map (fun (tag,count) -> (object
    method tag   = CTag.prepare (req # server) tag
    method count = count
  end)) stats in 

  let! list = ohm $ renderlist search (req # server) list next in

  let create = 
    if req # get "s" = None then None else
      Some (Action.url UrlStart.home (req # server) None)
  in
 
  let html = Asset_Network_List.render (object
    method navbar = (req # server,uid,None)
    method tags   = tags
    method search = String.concat " " search 
    method create = create
    method list   = list 
  end) in

  CPageLayout.core (req # server) title html res

let atoms_of_search search =     
  List.map (fun atom ->
    if BatString.starts_with atom "tag:" then `TAG (BatString.tail atom (String.length "tag:"))
    else `WORD atom) search

let () = UrlNetwork.def_root begin fun req res -> 

  let search = BatOption.default "" (req # get "q") in
  let search = BatString.nsplit search " " in
  let atoms = atoms_of_search search in 

  let! list, next = ohm $ MInstance.Profile.search ~count:10 (req # server) atoms in
  let  title      = `Network_Title in

  render search title list next req res

end

let () = UrlNetwork.def_more begin fun req res -> 

  let iid, search = req # args in 
  let atoms = atoms_of_search search in

  let! list, next = ohm $ MInstance.Profile.search ~start:iid ~count:10 (req # server) atoms in 

  let! list = ohm $ renderlist search (req # server) list next in 
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
