(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Field     = MJoinFields.Field

module MyDB = MModel.MainDB
module Design = struct
  module Database = MyDB
  let name = "category"
end

module Data = Fmt.Make(struct
    
  module Data = Fmt.Make(struct
    type json t = <
      t      : MType.t ;
      ins    : IInstance.t ;
     ?admins : bool = false ;
     ?grants : bool = false ;
     ?manual : bool = true ;
      entity : IEntity.t option ;
      list   : IAvatarGrid.t ;
     ?fields : Field.t list = [] ;
     ?propg  : IAvatarSet.t list = []
    > 
  end)

  type json t = <
    t      : MType.t ;
    iid    : IInstance.t ;
    admins : bool ;
    grants : bool ;
    manual : bool ;
    owner  : [ `Entity "t" of IEntity.t | `Event "e" of IEvent.t | `Group "g" of IGroup.t ] ;
    list   : IAvatarGrid.t ;
    fields : Field.t list ;
    propg  : IAvatarSet.t list 
  >

  let t_of_json json = 
    try t_of_json json with exn ->
      match Data.of_json_safe json with 
	| Some t -> begin
	  match t # entity with None -> raise exn | Some eid -> 
	    (object
	      method t = t # t
	      method iid = t # ins
	      method admins = t # admins
	      method grants = t # grants
	      method manual = t # manual
	      method owner  = `Entity eid
	      method list   = t # list 
	      method fields = t # fields
	      method propg  = t # propg
	     end) 
	end
	| None -> raise exn
	  
end)

module Tbl = CouchDB.Table(MyDB)(IAvatarSet)(Data)

type data = Data.t

module Signals = struct

  let on_join_admin_call,   on_join_admin   = Sig.make (Run.list_iter identity)
  let on_update_call,       on_update       = Sig.make (Run.list_iter identity)
  let on_token_grant_call,  on_token_grant  = Sig.make (Run.list_iter identity)
  let on_create_list_call,  on_create_list  = Sig.make (Run.list_iter identity)
  let on_upgrade_list_call, on_upgrade_list = Sig.make (Run.list_iter identity)

end

type 'relation t = {
  id       : 'relation IAvatarSet.id ;
  data     : data ;
  view     : bool O.run ;
  edit     : bool O.run ;
  admin    : bool O.run ;
  managers : MAccess.t O.run
}

let owner ( data : data ) = 
  Run.memo begin
    let  nil    = (fun _ -> `Nobody) in
    match data # owner with 
      | `Entity eid -> let! entity = ohm_req_or (return nil) $ MEntity.naked_get eid in
		       return (fun what -> MEntity.Satellite.access entity (`Group what))
      | `Group  gid -> let! group = ohm_req_or (return nil) $ MGroup.get gid in 
		       return (fun what -> MGroup.Satellite.access group (`Group what))
      | `Event  eid -> let! event = ohm_req_or (return nil) $ MEvent.get eid in
		       return (fun what -> MEvent.Satellite.access event (`Group what))
  end

let _relation_of_data actor id (data : data) = 
  let owner = owner data in
  {
    id    = id ;
    data  = data ;
    view  = ( let! f = ohm owner in MAccess.test actor [ f `Read ; f `Write ; f `Manage ] ) ;
    edit  = ( let! f = ohm owner in MAccess.test actor [           f `Write ; f `Manage ] ) ;
    admin = ( let! f = ohm owner in MAccess.test actor [                      f `Manage ] ) ;
    managers = ( let! f = ohm owner in return (`Union [ f `Write ; f `Manage ]) )
  }

let managers_of_data (data:data) = 
  let! f = ohm $ owner data in 
  return (`Union [ f `Write ; f `Manage ])  

let create asid iid owner = 

  let namer = MPreConfigNamer.load iid in 

  let iid  = IInstance.decay  iid in
  let asid = IAvatarSet.decay asid in    

  let! admin_asid = ohm $ MPreConfigNamer.avatarSet IGroup.admin namer in 

  let list = IAvatarGrid.gen () in 

  let owner, columns, propagate, join, grants = match owner with 

    | `Group (gid, gtmpl) ->  

      `Group gid, 
      PreConfig_Template.Groups.columns iid asid gtmpl,
      PreConfig_Template.Groups.propagate gtmpl,
      PreConfig_Template.Groups.join gtmpl,
      true

    | `Event (eid, evtmpl) ->  

      `Event eid, 
      PreConfig_Template.Events.columns iid asid evtmpl,
      [],
      PreConfig_Template.Events.join evtmpl,
      false
  in
 
  let! ()  = ohm $ Signals.on_create_list_call (list,asid,iid,columns) in

  let! propg = ohm $ Run.list_map 
    (fun name -> MPreConfigNamer.avatarSet name namer) 
    (propagate)
  in
  
  let o = object
    method t      = `Group
    method iid    = iid
    method admins = IAvatarSet.decay asid = admin_asid
    method grants = grants
    method manual = true
    method owner  = owner
    method list   = list
    method fields = List.map (fun f -> `Local f) join
    method propg  = propg
  end in
  
  Tbl.set asid o

let _get id = 
  Tbl.get (IAvatarSet.decay id)

let try_get actor id =
  let! group = ohm_req_or (return None) $ _get id in
  return $ Some (_relation_of_data actor id group)

let bot_get id = 
  let! group = ohm_req_or (return None) $ _get id in
  return $ Some {
    id    = id ;
    data  = group ;
    view  = return false ;
    edit  = return false ;
    admin = return false ;
    managers = managers_of_data group
  }

let naked_get = bot_get 

module Token = struct
  
  let get t = 
    if t.data # admins then `admin else
      if t.data # grants then `token else `contact

end

let refresh gid ~grants ~manual = 

  let update d = object
    method t      = `Group
    method iid    = d # iid
    method admins = d # admins
    method manual = manual
    method grants = grants
    method owner  = d # owner
    method list   = d # list
    method fields = d # fields
    method propg  = d # propg
  end in
  
  let! () = ohm $ Tbl.update (IAvatarSet.decay gid) update in 
  
  Signals.on_update_call gid

module Get = struct
    
  let id       t = t.id    	 
    	  
  let is_admin t = t.data # admins

  let owner    t = t.data # owner

  let manual   t = t.data # manual

  let instance t = t.data # iid

  let list     t = 
    (* Admin, write, read and list can see the list *)
    IAvatarGrid.Assert.list (t.data # list) 

  let listedit t = 
    (* Admin can configure the list *)
    IAvatarGrid.Assert.edit (t.data # list) 

  let write_access t = t.managers
            
end

module Can = struct 

  let list  t = 
    let! allow = ohm $ t.view in
    if allow then
      return $ Some {
	id    = IAvatarSet.Assert.list t.id ;
	data  = t.data ;
	view  = return true ;
	edit  = t.edit ;
	admin = t.admin ;
	managers = t.managers
      } 
    else return None
      
  let write t = 
    let! allow = ohm $ t.edit in
    if allow then
      return $ Some {
	id    = IAvatarSet.Assert.write t.id ;
	data  = t.data ;
	view  = return true ;
	edit  = return true ;
	admin = t.admin ;
	managers = t.managers 
      }
    else return None
      
  let admin t = 
    let! allow = ohm $ t.admin in
    if allow then 
      return $ Some {
	id    = IAvatarSet.Assert.admin t.id ;
	data  = t.data ;
	view  = return true ;
	edit  = return true ;
	admin = return true ;
	managers = t.managers
      }
    else return None

end

module Propagate = struct

  let _set id propg = 

    let update d = object
      method t      = `Group
      method iid    = d # iid
      method admins = d # admins
      method grants = d # grants
      method manual = d # manual
      method owner  = d # owner
      method list   = d # list
      method fields = d # fields
      method propg  = propg
    end in

    Tbl.update (IAvatarSet.decay id) update 

  (* Members in 'to_what' are added to 'what' automatically *)
  let add to_what what actor = 
    let      what = IAvatarSet.decay    what in 
    let   to_what = IAvatarSet.decay to_what in 
    let! to_group = ohm_req_or (return ()) $ try_get actor to_what in
    let! to_group = ohm_req_or (return ()) $ Can.admin to_group  in

    if List.mem what (to_group.data # propg) then return () else
      _set to_what (what :: to_group.data # propg)
   
  (* Members in 'from_what' are not added to 'what' anymore *)
  let rem from_what what = 
    let        what = IAvatarSet.decay      what in 
    let   from_what = IAvatarSet.decay from_what in      
    let! from_group = ohm_req_or (return ()) $ _get from_what in

    if List.mem what (from_group # propg) then  
      _set from_what (List.filter ((<>) what) from_group # propg)           
    else return ()

  let upgrade ~src ~dest action = 

    let src  = IAvatarSet.decay src in
    let dest = IAvatarSet.decay dest in 

    let! group = ohm_req_or (return ()) $ _get src in
    
    if List.mem dest (group # propg) then
      if action = `remove then
	_set src (List.filter ((<>) dest) group # propg)
      else
	return ()
    else 
      if action = `add then
	_set src (dest :: group # propg) 
      else
	return ()

  module InverseView = CouchDB.DocView(struct
    module Key = IAvatarSet
    module Value = Fmt.Unit
    module Doc = Data
    module Design = Design
    let name   = "propg_from" 
    let map    = "if (doc.t == 'grup' && doc.propg) 
                    for (var k in doc.propg)
                      emit(doc.propg[k],null);" 
  end)

  let get gid actor = 
    let  id    = IAvatarSet.decay gid in 
    let! items = ohm $ InverseView.doc id in
    
    return $ List.map begin fun item -> 
      let id = IAvatarSet.of_id (item # id) in 
      _relation_of_data actor id (item # doc)
    end items

  let get_direct gid = 
    let! group = ohm_req_or (return []) $ _get gid in
    return (group # propg)

end

module Fields = struct

  (* Worst case, keep only 50 fields. *)
  let max = 50

  let get t = 
    t.data # fields
    
  let set t fields = 
    let fields = BatList.take max fields in
    let update d = object
      method t      = `Group
      method iid    = d # iid
      method admins = d # admins
      method grants = d # grants
      method owner  = d # owner
      method manual = d # manual
      method list   = d # list
      method fields = fields
      method propg  = d # propg
    end in
    
    Tbl.update (IAvatarSet.decay t.id) update

  let of_group id = 
    let! group = ohm_req_or (return []) $ _get id in
    return (group # fields)

  let local gid = 
    let! fields = ohm $ of_group gid in
    return $ BatList.filter_map begin function 
      | `Local simple -> Some simple
      | `Profile _
      | `Import  _ -> None 
    end fields

  let flat gid = function 
    | `Local   simple  -> return (Some (MJoinFields.Flat.group false (IAvatarSet.decay gid) simple))
    | `Profile (r,p)   -> return (Some (MJoinFields.Flat.profile r p))
    | `Import  (r,g,s) -> let! fields = ohm $ of_group g in   
			  try return $ Some (BatList.find_map (function 
			    | `Local f when f # name = s -> 
			      Some (MJoinFields.Flat.group r g f) 
			    | _ -> None) fields) 
			  with Not_found -> return None
   

  let flatten gid = 

    let gid = IAvatarSet.decay gid in 
    let! fields = ohm $ of_group gid in 
    
    Run.list_filter (flat gid) fields

end

(* Reacting to entity refreshes ------------------------------------------------------------- *)
  
let () = 
  let! iid, gid, asid, template, _ = Sig.listen MGroup.Signals.on_bind_group in 
  create asid iid (`Group (IGroup.decay gid,template))

let () = 
  let! iid, eid, asid, template, _ = Sig.listen MEvent.Signals.on_bind_group in 
  create asid iid (`Event (IEvent.decay eid,template)) 

(* {{MIGRATION}} *)

let () = 
  let! eid, _, asid, _, kind, _, _, _, _ = Sig.listen MEntity.on_migrate in 

  let  gid = IGroup.of_id (IEntity.to_id eid) in

  if kind <> `Group then return false else 
    
    let! () = ohm $ Tbl.update asid begin fun avset ->
      (object
	method t = avset # t
	method iid = avset # iid
	method admins = avset # admins
	method grants = avset # grants
	method manual = avset # manual
	method owner  = `Group gid
	method list = avset # list
	method fields = avset # fields
	method propg = avset # propg
       end)
    end in 

    return true
      
    
