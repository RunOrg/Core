(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = CClient.define ~back:(Action.url UrlClient.Events.home) UrlClient.Events.def_see begin fun access -> 

  let e404 = O.Box.fill (Asset_Client_PageNotFound.render ()) in

  let! eid = O.Box.parse IEvent.seg in

  let! event = ohm_req_or e404 $ MEvent.view ~access eid in
  let! data  = ohm_req_or e404 $ MEvent.Get.data event in 

  let! admin  = ohm $ MEvent.Can.admin event in

  let  draft  = MEvent.Get.draft event in 

  let! feed   = ohm $ O.decay (MFeed.get_for_event access eid) in
  let! feed   = ohm $ O.decay (MFeed.Can.read feed) in
  let  feed   = if draft then None else feed in

  let! album  = ohm $ O.decay (MAlbum.get_for_owner access (`Event eid)) in
  let! album  = ohm $ O.decay (MAlbum.Can.read album) in
  let  album  = if draft then None else album in 

  let! folder = ohm $ O.decay (MFolder.get_for_event access eid) in
  let! folder = ohm $ O.decay (MFolder.Can.read folder) in
  let  folder = if draft then None else folder in 

  let  gid = MEvent.Get.group event in
  let! group = ohm $ O.decay (MGroup.try_get access gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.list group) in
  let  group = if draft then None else group in   

  let! sidebar = O.Box.add begin 

    let! the_seg = O.Box.parse UrlClient.Events.tabs in

    let! navig = ohm $ Run.list_map (fun seg -> 
      let! url = ohm $ O.Box.url [ fst IEvent.seg eid ; fst UrlClient.Events.tabs seg ] in
      return (object
	method url   = url
	method dark  = seg = `Album
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

    let url =
      if admin <> None then 
	Some (fun aid -> Action.url UrlClient.Events.join (access # instance # key) 
	  [ IEvent.to_string eid ; IAvatar.to_string aid ])
      else
	None
    in

    let! the_seg = O.Box.parse UrlClient.Events.tabs in 
    match the_seg with
      | `Wall   -> CWall.box (Some `Event) access feed     
      | `Album  -> CAlbum.box access album
      | `Folder -> CFolder.box access folder
      | `People -> CPeople.event_box ?url access group 

  end in
      
  O.Box.fill $ O.decay begin

    (* Top and side details ---------------------------------------------------------------- *)

    let! now  = ohmctx (#time) in

    let! name = ohm $ MEvent.Get.fullname event in
    let! pic  = ohm $ CPicture.large (MEvent.Get.picture event) in
    let  page = MEvent.Data.page data in 
    let  date = BatOption.map Date.to_timestamp (MEvent.Get.date event) in 
    let  address = MEvent.Data.address data in 
    
    let location = 
      match address with None -> None | Some address -> 
	Some (object
	  method url  = "http://maps.google.fr/maps?f=q&hl=fr&q="^address
	  method name = address
	 end)
    in

    (* Join box ------------------------------------------------------------------------------------------ *)

    let! join = ohm begin match group with None -> return None | Some group ->      
      let! status = ohm $ MMembership.status access gid in
      let  fields = MGroup.Fields.get group <> [] in
      return $ Some (CJoin.Self.render (`Event eid) (access # instance # key) 
		       ~gender:None ~kind:`Event ~status ~fields)
    end in 

    (* Administrator URLs -------------------------------------------------------------------------------- *)

    let pic_change = 
      if admin <> None then 
	Some (Action.url UrlClient.Events.picture (access # instance # key) [ IEvent.to_string eid ] )
      else 
	None
    in

    let invite = 
      if admin <> None && not draft then 
	Some (Action.url UrlClient.Events.invite (access # instance # key) [ IEvent.to_string eid ] )
      else 
	None
    in

    let admin = 
      if admin <> None then 
	Some (object
	  method invite = invite
	  method url = Action.url UrlClient.Events.admin (access # instance # key) [ IEvent.to_string eid ]
	end)
      else 
	None
    in

    (* Render the page ----------------------------------------------------------------------------------- *)

    Asset_Event_Page.render (object
      method pic        = pic
      method sidebar    = O.Box.render sidebar
      method admin      = admin
      method title      = name
      method join       = join
      method pic_change = pic_change 
      method date       = BatOption.map (fun t -> (t,now)) date
      method status     = BatOption.map (fun s -> (s :> VStatus.t)) (MEvent.Get.status event)
      method desc       = Some (MRich.OrText.to_text page |> OhmText.cut ~ellipsis:"…" 180)
      method time       = date
      method location   = location
      method details    = "/"
      method box        = O.Box.render contents 
    end)
  end
end
