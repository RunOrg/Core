(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define UrlClient.Events.def_see begin fun access -> 

  let e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let! eid = O.Box.parse IEntity.seg in

  let! entity = ohm_req_or e404 $ O.decay (MEntity.try_get access eid) in
  let! entity = ohm_req_or e404 $ O.decay (MEntity.Can.view entity) in

  let  draft  = MEntity.Get.draft entity in 

  let! feed   = ohm $ O.decay (MFeed.get_for_entity access eid) in
  let! feed   = ohm $ O.decay (MFeed.Can.read feed) in
  let  feed   = if draft then None else feed in

  let! album  = ohm $ O.decay (MAlbum.get_for_entity access eid) in
  let! album  = ohm $ O.decay (MAlbum.Can.read album) in
  let  album  = if draft then None else album in 

  let! folder = ohm $ O.decay (MFolder.get_for_entity access eid) in
  let! folder = ohm $ O.decay (MFolder.Can.read folder) in
  let  folder = if draft then None else folder in 

  let  gid = MEntity.Get.group entity in
  let! group = ohm $ O.decay (MGroup.try_get access gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.list group) in
  let  group = if draft then None else group in   

  let! sidebar = O.Box.add begin 

    let! the_seg = O.Box.parse UrlClient.Events.tabs in

    let! navig = ohm $ Run.list_map (fun seg -> 
      let! url = ohm $ O.Box.url [ fst IEntity.seg eid ; fst UrlClient.Events.tabs seg ] in
      return (object
	method url   = url
	method cls   = if seg = the_seg then "-selected" else "" 
	method size  = "-d0"
	method count = "" 
	method label = seg
      end))
      (BatList.filter_map identity 
	 [ Some `Wall ;
	   ( if group  <> None then Some `People else None ) ;
	   ( if album  <> None then Some `Album  else None ) ;
	   ( if folder <> None then Some `Folder else None ) ; 
	 ])
    in

    O.Box.fill (Asset_Event_Page_Sidebar.render navig)

  end in

  let! contents = O.Box.add begin 

    let! the_seg = O.Box.parse UrlClient.Events.tabs in 
    match the_seg with
      | `Wall   -> CWall.box access feed     
      | `People -> CPeople.event_box access group 
      | _       -> O.Box.fill (return (Html.str "O HAI, AGAINZ!"))

  end in
      
  O.Box.fill $ O.decay begin

    let! now  = ohmctx (#time) in

    let  tmpl = MEntity.Get.template entity in 
    let! name = ohm $ CEntityUtil.name entity in
    let! pic  = ohm $ CEntityUtil.pic_large entity in
    let! desc = ohm $ CEntityUtil.desc entity in
    let  date = BatOption.bind MFmt.float_of_date (MEntity.Get.date entity) in 
    let! loc  = ohm begin 
      match PreConfig_Template.Meaning.location tmpl with None -> return None | Some field -> 
	let! data = ohm $ CEntityUtil.data entity in
	return (try Some (Json.to_string (List.assoc field data)) with _ -> None)
    end in 
    
    let location = 
      match loc with None -> None | Some addr -> 
	Some (object
	  method url  = "http://maps.google.fr/maps?f=q&hl=fr&q="^addr
	  method name = addr
	 end)
    in

    Asset_Event_Page.render (object
      method pic        = pic
      method sidebar    = O.Box.render sidebar
      method admin      = None
      method title      = name
      method pic_change = None 
      method date       = BatOption.map (fun t -> (t,now)) date
      method status     = MEntity.Get.status entity 
      method desc       = BatOption.map (OhmText.cut ~ellipsis:"…" 180) desc
      method time       = date
      method location   = location
      method details    = "/"
      method box        = O.Box.render contents 
    end)
  end
end
