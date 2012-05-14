(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

module Grants      = CEntity_grants
module Sidebar     = CEntity_sidebar
module Edit        = CEntity_edit
module Unavailable = CEntity_unavailable
module View        = CEntity_view

module Home = struct

  module Create = struct
      
    open IInstance.Deduce
    open MVertical

    let precreate kind ~ctx =
      let  ins = IIsIn.instance ctx # myself in
      let  vertical  = ctx # instance # ver in
      let! templates  = ohm $ begin match kind with 
	| `Forum -> get_forum_templates (admin_create_forum ins) vertical 
	| `Album -> get_album_templates (admin_create_album ins) vertical 
	| `Event -> get_event_templates (admin_create_event ins) vertical 
	| `Group -> get_group_templates (admin_create_group ins) vertical
 	| `Poll  -> get_poll_templates  (admin_create_poll  ins) vertical 
	| `Subscription -> get_subscription_templates (admin_create_subscription ins) vertical 
	| `Course -> get_course_templates (admin_create_course ins) vertical
      end in 
      
      if templates = [] then return (fun callback -> callback None) else
	return (fun callback -> 
	  let  title    = VLabel.entity_chooser_title kind in
	  let! reaction = CEntityCreate.pick_templates ~templates ~title ~ctx in
	  callback $ Some reaction)
      
  end

  (* A box containing a list of entities *)

  let list_box ~title ~empty ~precreate ~list ~public_link ~past ~ctx = 

    O.Box.decide begin fun _ _ -> 

      let i18n = ctx # i18n in
      let owner = IIsIn.Deduce.is_admin (ctx # myself) in
      
      let pc_reaction, pc_label = precreate in 
      
      let! precreate = ohm $ pc_reaction owner in 
      
      return begin 
	let! precreate = precreate in 
	O.Box.leaf 
	  begin fun input url ->
	    
	    let! entities = ohm $ list ctx in
	    
	    let date e = BatOption.default "99991231" (MEntity.Get.date e) in
	    
	  (* Sort in ascending order - future treatment will reverse this order *)
    	    let entities = List.stable_sort (fun a b  -> compare (date a) (date b)) entities in
	    
	  (* This part extracts the data for all entities in the list. *)
	    let! list     = ohm begin
	      entities
	      |> Run.list_map begin fun entity -> 
		
		let eid = IEntity.decay $ MEntity.Get.id entity in 
		let gid = MEntity.Get.group entity in
		
		let url = 
		  UrlR.build (ctx # instance) 
		    Box.Seg.(CSegs.(root ++ root_pages ++ entity_id ++ entity_tabs)) 
		    ((((),`Entity),Some eid),`Info)
		in
		
		let! stats  = ohm $ MMembership.InGroup.count gid in
		let! status = ohm $ MMembership.status ctx gid in 
		
		let join = 
		  VJoin.Button.render status 
		    (UrlJoin.self_edit # build (ctx # instance) eid)
		in
		
		let lines = 
		  (if stats # count > 0 then 		
		      [(object
			method value = stats # count
			method css   = `Users
		      end)]
		   else [])
		    
		  @ (if owner <> None && stats # pending > 0 then
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
		
		return (MEntity.Get.date entity, MEntity.Get.end_date entity, (object
		  method desc   = desc
		  method name   = name
		  method img    = img
		  method stats  = lines
		  method draft  = MEntity.Get.draft entity
		  method url    = url
		  method join   = join 
		  method access = Some (`Entity (MEntity.Get.real_access entity))
		end))
	      end
	    end in
	    
	    let public_link = 
	      if not public_link then None else 
		if List.exists MEntity.Get.public entities then
		  Some (UrlSubscription.start # build (ctx # instance))
		else None
	    in
	    
	    let action i18n =
	      match precreate with
		| None -> Ohm.View.str "&nbsp;" 
		| Some reaction -> 
		  VCore.GreenButton.render     
		    (Js.runFromServer (input # reaction_url reaction), pc_label) i18n
	    in
	    
	    let now = Unix.gettimeofday () in
	    
	    let list, list_timed, list_past = 
	      List.fold_left begin fun (list,timed,past) (date,end_date,item) -> 
		match BatOption.bind MFmt.float_of_date date with 
		  | None -> (item :: list, timed, past)
		  | Some time -> 
		    
		    let endtime = 
		      match BatOption.bind MFmt.float_of_date end_date with 
			| None      -> time +. 24. *. 3600.
			| Some time -> time +. 24. *. 3600.
		    in
		    
		    if endtime < now then (list, timed, item :: past) else
		      
		      let timed = match timed with
			| (d,t,l) :: r when d = date -> (d,t,item :: l) :: r
			| other -> (date,time,[item]) :: other
		      in
		      
		      (list, timed, past)
			
	      end ([],[],[]) list
	    in
	    
	    let list_timed = 
	      List.map (fun (_,t,l) -> (object
		method date = t
		method list = l
	      end)) list_timed 
	    in 
	    
	    let empty = 
	      if list = [] && list_timed = [] && list_past = [] 
	      then Some (object
		method image   = fst empty 
		method message = snd empty 
	      end)
	      else None
	    in
	    
	    let list_past = 
	      if list_past <> []
	      then Some (object
		method label = past
		method list  = list_past
	      end)
	      else None
	    in
	    
	    return (
	      VEntity.Home.render (object
		method access = Some (`Page `Public)
		method title  = title
		method list   = list
		method empty  = empty
		method timed_list  = list_timed
		method past_list   = list_past
		method action      = action
		method public_link = public_link
	      end) i18n
	    )
	  end    
      end
    end

  (* The home of any kind of entity *)

  let home_box kind ~(ctx:'any CContext.full) = 

    let precreate owner =
      let  none  = return (fun callback -> callback None) in
      let! owner = req_or none owner in 
      let ctx = CContext.evolve_full owner ctx in
      Create.precreate kind ~ctx
    in
    
    let empty = 
      VIcon.empty_of_entity_kind kind, 
      VLabel.empty_entity_list kind
    in      
    
    list_box 
      ~title:(VLabel.of_entity_kind `plural kind)
      ~empty
      ~precreate:(precreate,VLabel.create_entity_kind kind) 
      ~public_link:false
      ~list:(fun ctx -> MEntity.All.get_by_kind ctx kind)      
      ~past:(VLabel.past_entity_list kind) 
      ~ctx 
     

  (* The list of access-granting entities *)
      
  let grants_box ~ctx =

    let precreate owner = return $ optional owner (fun owner -> 
      let ctx = CContext.evolve_full owner ctx in
      Grants.edit ~ctx
    ) in

    let empty = VIcon.Large.key, `label "grants.empty" in

    list_box 
      ~title:(`label "menu.grants")
      ~empty 
      ~precreate:(precreate,`label "grants.edit")
      ~public_link:true
      ~list:(MEntity.All.get_granting)
      ~past:(`label "grants.past")
      ~ctx

  (* Calendar entities *)
      
  let calendar_box ~ctx =

    let empty = VIcon.Large.key, `label "calendar.empty" in

    list_box 
      ~title:(`label "menu.calendar")
      ~empty 
      ~precreate:((fun _ -> return (fun c -> c None)),`label "")
      ~public_link:true
      ~list:(MEntity.All.get_future)
      ~past:(`label "events.past")
      ~ctx

end
