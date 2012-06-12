(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render ?tag title list req res = 

  let uid = 
    match CSession.check req with 
      | `None     -> None
      | `Old cuid -> Some (ICurrentUser.decay cuid) 
      | `New cuid -> Some (ICurrentUser.decay cuid)
  in

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
      method desc = profile # desc
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
    
