(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let list i18n user = O.Box.leaf begin fun input (prefix,tag_opt) ->

  let count = 20 in

  let! list, _ = ohm begin match tag_opt with 
    | Some tag -> MInstance.Profile.by_tag ~count tag 
    | None     -> MInstance.Profile.all ~count () 
  end in

  let render_tag tag = object
    method url = UrlMe.build (input # segments) (prefix,Some (String.lowercase tag))
    method tag = String.lowercase tag
  end in

  let render_profile data = 
    let! pic = ohm $ CPicture.small data # pic in 
    return (object
      method picture = pic
      method url     = 
	if data # unbound then
	  UrlMe.build
	    O.Box.Seg.(root ++ UrlSegs.me_pages ++ UrlSegs.me_network_tabs `Profile ++ UrlSegs.instance_id) 
	    ((((),`Network),`Profile),Some (data # id))
	else
	  UrlR.index # key_build data # key
      method name    = data # name
      method desc    = VText.head 300 (BatOption.default "" data # desc)
      method tags    = List.map render_tag data # tags
    end)
  in

  let! profiles = ohm $ Run.list_map render_profile list in
    
  return $ View.foreach (fun profile -> VMe.Network.SearchItem.render profile i18n) profiles
    
end

let box i18n user = 
  let content = "list" in
  O.Box.node begin fun input (prefix,_) -> 
    return [content,list i18n user] , 
    begin
      
      let! tag_stats = ohm $ MInstance.Profile.tag_stats () in
      let render_tag (tag,count) = object
	method tag   = String.lowercase tag
	method count = count
	method url   = UrlMe.build (input # segments) (prefix,Some (String.lowercase tag)) 
      end in
      
      return $ VMe.Network.Search.render (object
	method list = (input # name, content) 
	method tags = List.map render_tag (List.filter (fun (tag,count) -> count > 1) tag_stats) 
      end) i18n

    end
  end
  |> O.Box.parse UrlSegs.string
