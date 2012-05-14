(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Import = CAdd_import
module Search = CAdd_search
module From   = CAdd_from

let tabs ~ctx ~directory entity = 

  let access = MEntity.Get.grants entity in 

  let list = BatList.filter_map identity [

    Some (CTabs.fixed `Import (`label "members.add.import") 
	    (lazy (Import.box ~ctx entity))) ;

    BatOption.map (fun directory -> 
      CTabs.fixed `Search (`label "members.add.search") 
	(lazy (Search.box ~ctx ~directory entity))
    ) directory ;

    Some (CTabs.fixed `FromEntity (`label "members.add.fromEntity") 
	    (lazy (From.box ~ctx entity))) ;

  ] in

  CTabs.box
    ~list
    ~url:(UrlR.build (ctx # instance))
    ~i18n:(ctx # i18n)
    ~default:(if access then `Import else if directory = None then `FromEntity else `Search)
    ~seg:(CSegs.add_tabs)

let entity_box ~ctx entity = 
  let content = "c" in
  O.Box.node
    begin fun bctx _ ->

      begin 

	let! directory = ohm (MInstanceAccess.can_view_directory ctx) in	
	return [content, tabs ~ctx ~directory entity]

      end, begin
	
	let eid  = IEntity.decay $ MEntity.Get.id entity in 
	let name = CName.of_entity entity in 
	
	let entity_url = 	 
	  UrlR.build (ctx # instance) 
	    O.Box.Seg.(CSegs.(root ++ root_pages ++ entity_id ++ entity_tabs)) 
	    ((((),`Entity),Some eid),`Admin_People)
	in

	let home_url = 
	  UrlR.build (ctx # instance) 
	    O.Box.Seg.(root ++ UrlSegs.root_pages) ((), `Home)  
	in
	
	let data = object
	  method box         = (bctx # name, content) 
	  method entity_url  = entity_url
	  method entity_name = name
	  method home        = home_url
	  method asso        = ctx # instance # name 
	end in 
	
	return $ VAdd.Page.render data (ctx # i18n) 
      end
  end

let list_box ~ctx = 
  O.Box.leaf begin fun bctx _ -> 

    let! entities = ohm $ MEntity.All.get_administrable_granting ctx in

    let! list = ohm begin
      entities |> Run.list_map begin fun entity -> 

	let eid = IEntity.decay $ MEntity.Get.id entity in 
	let gid = MEntity.Get.group entity in
	
	let url = UrlR.build (ctx # instance) 
	  O.Box.Seg.(root ++ UrlSegs.root_pages ++ UrlSegs.entity_id) 
	  (((),`AddMembers),Some eid)
	in
	
	let! stats  = ohm $ MMembership.InGroup.count gid in
	
	let lines = 
	  (if stats # count > 0 then 		
	      [(object
		method value = stats # count
		method css   = `Users
	      end)]
	   else [])
		
	  @ (if stats # pending > 0 then
	      [(object 
		method value = stats # pending
		method css   = `Pending
	      end)]
	    else [])
	in
	
	let desc = MEntity.Get.summary entity in
	let name = CName.of_entity entity in
	
	let! img = ohm begin 
	  match MEntity.Get.picture entity with 
	    | None -> return None
	    | Some _ ->
	      let! url = ohm (ctx # picture_small (MEntity.Get.picture entity)) in
	      return (Some url)
	end in
	
	return (object
	  method desc   = desc
	  method name   = name
	  method img    = img
	  method stats  = lines
	  method url    = url
	end)
      end
    end in

    let public_link =       
      if List.exists MEntity.Get.public entities then
	Some (UrlSubscription.start # build (ctx # instance))
      else None
    in

    let data = object
      method list = list
      method home = UrlR.build (ctx # instance) 
	O.Box.Seg.(root ++ UrlSegs.root_pages) ((), `Home)  
      method asso = ctx # instance # name 
      method send = public_link
    end in 

    return $ VAdd.Access.render data (ctx # i18n) 

  end

let box ~ctx = 
  O.Box.decide begin fun _ (_,eid_opt) -> 
    let! entity = ohm $ Run.opt_bind (MEntity.try_get ctx) eid_opt in 
    let! entity = ohm $ Run.opt_bind (MEntity.Can.admin) entity in 
    match entity with 
      | None        -> return $ list_box   ~ctx
      | Some entity -> return $ entity_box ~ctx entity
  end
  |> O.Box.parse UrlSegs.entity_id
