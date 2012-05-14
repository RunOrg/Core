(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let box ~(ctx:'any CContext.full) ~entity = 
  let i18n = ctx # i18n in 
  
  let render ~entity_data = 
    
    O.Box.leaf begin fun input _ -> 
      
      let layout = MEntity.Data.info entity_data in 
      
      let data n    = 
	try Fmt.real_value (List.assoc n (MEntity.Data.data entity_data))
	with Not_found -> None
      in
      let formatter = VVertical.Template.formatter i18n in
      
      let eid = IEntity.decay (MEntity.Get.id entity) in

      let! actions = ohm begin 
	let! administrable = ohm $ MEntity.Can.admin entity in
	if administrable = None then 
	  return (fun _ c -> c)
	else
	  return $ VCore.ActionBox.render (object
	    method title   = Some (`label "entity.action.title") 
	    method actions = [
	      `Link (object
		method label = `label "edit"
		method url   = (UrlEntity.edit ()) # build (ctx # instance) eid
		method img   = VIcon.pencil
	      end) ;
	      `Link (object
		method label = `label "entity.action.invite"
		method url   =   
		  UrlR.build (ctx # instance) 
		    O.Box.Seg.(UrlSegs.(root ++ root_pages ++ entity_id)) 
		    ((((),`AddMembers),Some eid))
		method img   = VIcon.group_add
	      end) ;
	    ]
	  end)
      end in
      
      let public = 
	if MEntity.Get.grants entity
	&& MEntity.Get.public entity 
	&& not (MEntity.Get.draft entity)
	then Some ((UrlSubscription.form ()) # build (ctx # instance) (MEntity.Get.id entity))
	else None
      in
      
      return $ VEntity.View.info 
	~public
	~formatter
	~description:(MEntity.Data.description entity_data)
	~data
	~layout
	~actions
	~i18n
    end   
  in 

  O.Box.decide begin fun _ _ ->
    
    let! entity_data = ohm_req_or
      (return (O.Box.error (fun _ _ -> return Js.panic)))
      (MEntity.Data.get (MEntity.Get.id entity)) in
    
    return (render ~entity_data)
      
  end
