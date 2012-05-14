(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives 

module Sidebar     = CEntity_sidebar
module Unavailable = CEntity_unavailable
module Edit        = CEntity_edit
module Info        = CEntity_view_info 
module Directory   = CEntity_view_directory
module Grid        = CEntity_view_grid
module Wall        = CEntity_view_wall 
      
let tabs ~(ctx:[`Unknown] CContext.full)  ~info ~entity ~group = 

  (* First, extract all necessary information from the database and the 
     parameters. *)

  let! admin_entity = ohm $ MEntity.Can.admin entity in

  let! wall         = ohm $ MFeed.get_for_entity ctx (MEntity.Get.id entity) in
  let! wall         = ohm $ MFeed.Can.read wall in

  let! album        = ohm $ MAlbum.get_for_entity ctx (MEntity.Get.id entity) in 
  let! album        = ohm $ MAlbum.Can.read album in

  let! folder       = ohm $ MFolder.get_for_entity ctx (MEntity.Get.id entity) in
  let! folder       = ohm $ MFolder.Can.read folder in

  let! write_group  = ohm $ Run.opt_bind MGroup.Can.write group in 
  let! list_group   = ohm $ Run.opt_bind MGroup.Can.list  group in 
  let! admin_group  = ohm $ Run.opt_bind MGroup.Can.admin group in 

  let token_ctx    = match CClient.is_token (ctx # myself) with 
    | None      -> None
    | Some isin -> Some (CContext.evolve_full isin ctx)
  in
  
  (* A simple helper tool for defining sub-tabs. *)
  let some value callback = BatOption.bind callback value in 
  let not_ag     callback = if CContext.is_ag ctx then None else callback () in

  let list = [
    `Info,            ( Some (Info.box ~ctx ~entity) ) ;
    `Admin_Edit,      ( let! entity = some admin_entity in 
			let! ctx    = some token_ctx in 
			Some (Edit.root_box ~ctx ~entity) ) ;
    `People,          ( let! group  = some list_group in
			let! ctx    = some token_ctx in
			Some (Directory.box ~ctx ~group) ) ;
    `Admin_People,    ( let! group  = some write_group in 
			let! ctx    = some token_ctx in 
			Some (Grid.box ~ctx ~entity ~group) ) ;
    `Admin_Stats,     ( let! group  = some write_group in 
			let! ctx    = some token_ctx in 
			let! ()     = not_ag in
			Some (CStats.root_box ~ctx ~group) ) ;
    `Wall,            ( let! wall   = some wall in
			Some (Wall.box ~ctx ~wall) ) ;
    `Chat,            ( let! wall   = some wall in
			Some (CChat.box ~ctx ~wall) ) ;
    `Album,           ( let! album  = some album in
			let! ctx    = some token_ctx in
			Some (CAlbum.box ~ctx ~album) ) ;
    `Votes,           ( let has = MEntity.Satellite.has_votes entity in
			if has then Some (CVote.box ~ctx ~entity) else None ) ;
    `Folder,          ( let! folder = some folder in
			let! ctx    = some token_ctx in 
			Some (CFolder.box ~ctx ~folder) ) ;
    `Admin_Fields,    ( let! group  = some admin_group in 
			let! ctx    = some token_ctx in 
			let! ()     = not_ag in
			Some (CLists.field_box ~ctx ~group) ) ;
    `Admin_Columns,   ( let! group  = some admin_group in 
			let! ctx    = some token_ctx in 
			let! ()     = not_ag in
			Some (CLists.column_box ~ctx ~group) ) ;
    `Admin_Propagate, ( let! group  = some admin_group in 
			let! ctx    = some token_ctx in 
			let! ()     = not_ag in
			Some (CMember.Link.link_box ~ctx ~group ~entity) ) ;
    `Admin_Payment,   ( let! entity = some admin_entity in 
			let! ctx    = some token_ctx in
			let! ()     = not_ag in
			Some (CAccounting.entity_tab ~ctx ~entity) ) ;
    `Admin_Rights,    ( let! entity = some admin_entity in 
			let! ctx    = some token_ctx in 
			Some (CEntity_access.box ~ctx ~entity))
  ] in

  (* Filter empty tabs and feed it to view. *)
  let tabs = BatList.filter_map (fun (k,v) -> BatOption.map (fun v -> (k,v)) v) list in
  
  return $ Sidebar.tabs ctx info (Unavailable.box ~i18n:(ctx#i18n)) `Info tabs      
    
(* The box left behind when an entity is deleted *)
    
let deleted_box ~(ctx:[`Unknown] CContext.full) ~entity ~avatar = 
  let i18n = ctx # i18n in
  O.Box.leaf 
    begin fun input _ ->
      let url_above = match MEntity.Get.kind entity with 
	| `Event        -> UrlEvent.home # build (ctx # instance)
	| `Group        -> UrlGroup.home # build (ctx # instance)
	| `Subscription -> UrlSubscription.home # build (ctx # instance)
	| `Forum        -> UrlForum.home # build (ctx # instance)
	| `Poll         -> UrlPoll.home # build (ctx # instance)
	| `Album        -> UrlAlbum.home # build (ctx # instance) 
	| `Course       -> UrlCourse.home # build (ctx # instance)
      in
      
      let! details = ohm (MAvatar.details avatar) in
      
      let! picture = ohm (ctx # picture_small (details # picture)) in
      
      return (
	VEntity.deleted 
	  ~url_home:((UrlEntity.root ()) # build (ctx # instance) (MEntity.Get.id entity))
	  ~url_asso:(UrlR.home # build (ctx # instance))
	  ~name_asso:(ctx # instance # name)
	  ~url_above
	  ~kind:(MEntity.Get.kind entity)
	  ~pic:picture
	  ~url:(UrlProfile.page ctx avatar)
	  ~name:(CName.get i18n details)
	  ~i18n 
      )
    end
    
  (* The root box decides whether it should show the tabs box, the deleted box, 
     or an access denied box *)
    
let root_box ~(ctx:[`Unknown] CContext.full) = 
  let i18n = ctx # i18n in 

  let root entity = 

    let    eid = IEntity.decay $ MEntity.Get.id entity in 
    
    let    gid = MEntity.Get.group entity in 
    let! group = ohm $ MGroup.try_get ctx gid in
       
    let! picture = ohm $ CPicture.large (MEntity.Get.picture entity) in

    let picture = if MEntity.Get.picture entity = None then None else Some picture in 

    let url_list = match MEntity.Get.kind entity with 
      | `Event        -> UrlEvent.home # build (ctx # instance)
      | `Group        -> UrlGroup.home # build (ctx # instance)
      | `Subscription -> UrlSubscription.home # build (ctx # instance)
      | `Forum        -> UrlForum.home # build (ctx # instance)
      | `Poll         -> UrlPoll.home # build (ctx # instance)
      | `Album        -> UrlAlbum.home # build (ctx # instance)
      | `Course       -> UrlCourse.home # build (ctx # instance)
    in
      
    let! status = ohm $ MMembership.status ctx gid in 

    let join bctx = 
      if group = None then 
	(fun i18n -> View.str "&nbsp;")
      else
	VJoin.Button.render status 
	 (UrlJoin.self_edit # build (ctx # instance) eid)
    in

    let info bctx = object
      method url_asso  = UrlR.home # build (ctx # instance)
      method url_list  = url_list
      method name_asso = ctx # instance # name
      method name      = CName.of_entity entity
      method kind      = MEntity.Get.kind entity 
      method desc      = MEntity.Get.summary entity
      method picture   = picture 
      method join      = join bctx
      method invited   = status = `Invited
      method eid       = eid
    end in
    
    tabs ~ctx ~info ~entity ~group

  in
  
  O.Box.decide begin fun _ (_,eid) ->
    
    let! entity_opt = ohm $
      Run.opt_bind (MEntity.try_get ctx) eid
    in
    
    let! entity  = req_or (return (Unavailable.box ~i18n)) entity_opt in
    let! visible = ohm $ MEntity.Can.view entity in
	
    match visible with 
      | Some entity -> root entity
      | None ->
	
	match MEntity.Get.deleted entity with 
	  | None        -> return (Unavailable.box ~i18n) 
	  | Some avatar -> return (deleted_box ~ctx ~entity ~avatar)
	    
  end

  |> O.Box.parse CSegs.entity_id
      
