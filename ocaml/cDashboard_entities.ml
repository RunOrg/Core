(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives
open O

open CDashboard_common

let render ctx entity = 
 
  let! picture = ohm $ ctx # picture_small (MEntity.Get.picture entity) in
  let  gid  = MEntity.Get.group entity in 
  
  let! status = ohm $ MMembership.status ctx gid in 

  let  name = BatOption.default (`label "entity.untitled") $ MEntity.Get.name entity in
  let  url =
    UrlR.build (ctx # instance) 
      Box.Seg.(CSegs.(root ++ root_pages ++ entity_id ++ entity_tabs)) 
      ((((),`Entity),Some (IEntity.decay (MEntity.Get.id entity))),`Info)
  in
  
  return begin object
    method picture = picture
    method name    = name
    method url     = url
    method status  = status
  end end

let async kind ~ctx =
  let name = VLabel.entity_kind_root kind in 
  O.Box.reaction name begin fun self bctx req res ->

    let! entities = ohm $ MEntity.All.get_by_kind ctx kind in
    
    (* Hack: simulate reverse order *)
    let entities = List.rev entities in

    let shown = 4 in
    let shown = if List.length entities = shown + 1 then shown + 1 else shown in 

    let! list = ohm $ Run.list_map (render ctx) (BatList.take shown entities) in
    let remaining = List.length entities - shown in

    let  view = VDashboard.EntityList.render
      (object
	method list = list
	method rest =
	  if list = [] then Some 0 else 
	    if remaining < 2 then None else Some remaining 
       end)
      (ctx # i18n)
    in
    
    return (Action.json (Js.Html.return view) res)

  end

let block kind ~ctx = 

  let url = match kind with 
    | `Event  -> `Events
    | `Group  -> `Groups
    | `Subscription -> `Subscriptions
    | `Forum  -> `Forums
    | `Album  -> `Albums
    | `Poll   -> `Polls
    | `Course -> `Courses
  in
  
  return (fun callback -> 
    let! inner = async kind ~ctx in
    callback (Some (fun bctx (prefix,_) ->
      element
	~icon:(VIcon.of_entity_kind kind)
	~url:(UrlR.build (ctx # instance) (bctx # segments) (prefix,url))
	~base:(VLabel.entity_kind_root kind)
	~load:(Some (bctx # reaction_url inner))
	~green:None
	~access:`Public
	~hasdesc:false
    ))
  )  
