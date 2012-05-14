(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module TaskArgs = Fmt.Make(struct
  type json t = <
    mode    : [ `invite | `add ] ;
    sources : IGroup.t list ;
    group   : IGroup.t ;
    from    : IAvatar.t 
  >
end)

let task = 
  Task.register "add-from-groups" TaskArgs.fmt begin fun args _ ->
    
    let continue list = 
      if list = [] then return (Task.Finished args) else
	return (Task.Partial ((object
	  method mode    = args # mode
	  method sources = list
	  method group   = args # group
	  method from    = args # from
	end), 0, 1))
    in 

    match args # sources with 
      | [] -> continue []
      | head :: tail -> 

	(* Restoring properties *)
	let from   = IAvatar.Assert.is_self (args # from) in
	let gid    = IGroup.Assert.write (args # group) in
	let source = IGroup.Assert.list  head in
	
	let actions = match args # mode with 
	  | `invite -> [ `Invite ; `Accept true ] 
	  | `add    -> [ `Accept true ; `Default true ]
	in

	let add_avatar (_,aid) = 
	  MMembership.admin ~from gid aid actions 
	in
    
	(* Running loop *)
	
	let! group = ohm_req_or (continue tail) (MGroup.naked_get gid) in
	let! list  = ohm $ MMembership.InGroup.all source `Validated in
	let! _     = ohm (Run.list_map add_avatar list) in
    
	continue tail 
	
  end

module AddArgs = Fmt.Make(struct
  type json t = <
    mode : [ `add | `invite ] ;
    list : IEntity.t list
  >
end)

let add ~ctx entity = 
  O.Box.reaction "add" begin fun _ bctx _ res ->

    let panic = return $ O.Action.javascript Js.panic res in 

    (* Extract arguments *)
    
    let! args = req_or panic $ AddArgs.of_json_safe (bctx # json) in

    let list  = BatList.sort_unique compare (args # list) in 

    let eid   = IEntity.decay $ MEntity.Get.id entity in
    let gid   = MEntity.Get.group entity in 

    let! entities = ohm $ Run.list_map (MEntity.try_get ctx) list in
    let  entities = BatList.filter_map identity entities in 

    let! entities = ohm $ Run.list_map (MEntity.Can.view) entities in 
    let  groups   = BatList.filter_map (BatOption.map MEntity.Get.group) entities in

    let! groups   = ohm $ Run.list_map (MGroup.try_get ctx) groups in 
    let  groups   = BatList.filter_map identity groups in 

    let! sources  = ohm $ Run.list_map (MGroup.Can.list) groups in 
    let  sources  = BatList.filter_map (BatOption.map MGroup.Get.id) sources in 

    let! self = ohm $ ctx # self in 

    (* Perform addition *)

    let! _ = ohm $ MModel.Task.call task (object
      method from    = IAvatar.decay self
      method sources = List.map IGroup.decay sources
      method group   = gid
      method mode    = args # mode
    end) in

    (* Redirect after a delay *)

    let time = 7000.0 in

    let url = UrlR.build (ctx # instance)
      O.Box.Seg.(UrlEntity.segments ++ UrlSegs.entity_tabs)
      ((((),`Entity),Some eid),`Admin_People)
    in
    
    return $ O.Action.javascript (JsCode.seq [
      Js.message (I18n.get (ctx # i18n) (`label "changes.soon")) ;
      JsBase.delay time (JsBase.boxLoad url) 
    ]) res

  end

let render ctx entity = 
 
  let! picture = ohm $ ctx # picture_small (MEntity.Get.picture entity) in
  let  name = BatOption.default (`label "entity.untitled") $ MEntity.Get.name entity in
  
  return begin object
    method picture = picture
    method name    = name
    method id      = IEntity.decay (MEntity.Get.id entity) 
  end end

let list ~ctx = 
  O.Box.reaction "list-entities" begin fun _ bctx _ res ->

    let kind = BatOption.default "" (bctx # post "kind") in
    let kind = BatOption.default `Group (MEntityKind.of_json_safe (Json_type.String kind)) in

    let! entities = ohm $ MEntity.All.get_administrable_by_kind ctx kind in
    
    (* Hack: simulate reverse order *)
    let entities = List.rev entities in

    let! list = ohm $ Run.list_map (render ctx) entities in

    let  view = VAdd.FromBlockLine.render list (ctx # i18n) in
    
    return (O.Action.json (Js.Html.return view) res)

  end

let box ~ctx entity = 
  let! list_reaction = list ~ctx in 
  let! add_reaction  = add  ~ctx entity in 
  O.Box.leaf begin fun bctx _ -> 

    let kind k = 
      let id = Util.uniq () in
      if CContext.is_ag ctx && k <> `Group && k <> `Event then
	None
      else 
	Some (object
	  method id   = id
	  method url  = bctx # reaction_url list_reaction 
	  method kind = k
	end)
    in

    return $ VAdd.From.render (object
      method kind = kind
      method url  = bctx # reaction_url add_reaction
    end) (ctx # i18n) 

  end
