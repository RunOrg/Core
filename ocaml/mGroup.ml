(* © 2012 MRunOrg *)

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
  type json t = <
    t      : MType.t ;
    ins    : IInstance.t ;
    ?admins : bool = false ;
    ?grants : bool = false ;
    ?manual : bool = true ;
    entity : IEntity.t option ;
    list   : IAvatarGrid.t ;
    ?fields : Field.t list = [] ;
    ?propg  : IGroup.t list = []
  > 
end)

module MyTable = CouchDB.Table(MyDB)(IGroup)(Data)

type data = Data.t

module Signals = struct

  let on_join_admin_call,   on_join_admin   = Sig.make (Run.list_iter identity)
  let on_update_call,       on_update       = Sig.make (Run.list_iter identity)
  let on_token_grant_call,  on_token_grant  = Sig.make (Run.list_iter identity)
  let on_create_list_call,  on_create_list  = Sig.make (Run.list_iter identity)
  let on_upgrade_list_call, on_upgrade_list = Sig.make (Run.list_iter identity)

end

type 'relation t = {
  id       : 'relation IGroup.id ;
  data     : data ;
  view     : bool O.run ;
  edit     : bool O.run ;
  admin    : bool O.run ;
  managers : MAccess.t O.run
}

let _relation_of_data context id data = 
  let owner = Run.memo begin
    let  nil    = (fun _ -> `Nobody) in
    let! eid    = req_or (return nil) $ data # entity in
    let! entity = ohm_req_or (return nil) $ MEntity.try_get context eid in
    return (fun what -> MEntity.Satellite.access entity (`Group what))
  end in
  {
    id    = id ;
    data  = data ;
    view  = ( let! f = ohm owner in MAccess.test context [ f `Read ; f `Write ; f `Manage ] ) ;
    edit  = ( let! f = ohm owner in MAccess.test context [           f `Write ; f `Manage ] ) ;
    admin = ( let! f = ohm owner in MAccess.test context [                      f `Manage ] ) ;
    managers = ( let! f = ohm owner in return (`Union [ f `Write ; f `Manage ]) )
  }

let managers_of_data data = 
  Run.memo begin 
    let! eid    = req_or (return `Nobody) $ data # entity in
    let! entity = ohm_req_or (return `Nobody) $ MEntity.naked_get eid in
    let  f x = MEntity.Satellite.access entity (`Group x) in
    return (`Union [ f `Write ; f `Manage ])
  end

let create gid admin iid eid diffs = 

  let namer = MPreConfigNamer.load iid in 

  let iid = IInstance.decay iid in
  let gid = IGroup.decay    gid in    
  let eid = IEntity.decay   eid in 

  let list = IAvatarGrid.gen () in 
  let! ()  = ohm $ Signals.on_create_list_call (list,gid,iid,diffs # columns) in

  let! propg = ohm $ MGroupPropagate.Entity.apply_diffs [] namer (diffs # propagate) in
  
  let o = object
    method t      = `Group
    method ins    = iid
    method admins = admin
    method grants = false
    method manual = true
    method entity = Some eid
    method list   = list
    method fields = MJoinFields.apply_diff [] (diffs # join)
    method propg  = propg
  end in
  
  let! data = ohm $ MyTable.transaction gid (MyTable.insert o) in
		   
  return {
    id    = IGroup.Assert.admin gid ;
    data  = data ;
    view  = return true ;
    edit  = return true ;
    admin = return true ;
    managers = managers_of_data data ;
  } 

let _get id = 
  MyTable.get (IGroup.decay id)

let version_update gid diffs =

  let! group = ohm_req_or (return ()) $ _get gid in

  let namer = MPreConfigNamer.load (group # ins) in
  
  (* Update group fields *)
  let! () = ohm begin 
    if diffs # join = [] && diffs # propagate = [] then return () else
      
      let update gid =
	
	let! group = ohm_req_or (return ((),`keep)) $ MyTable.get gid in 
	let! propg = ohm $ MGroupPropagate.Entity.apply_diffs
	  (group # propg) namer (diffs # propagate)
	in

	return ((), `put (object
	  method t      = `Group
	  method ins    = group # ins
	  method admins = group # admins
	  method grants = group # grants
	  method manual = group # manual
	  method entity = group # entity
	  method list   = group # list
	  method propg  = propg
	  method fields = MJoinFields.apply_diff (group # fields) (diffs # join) 
	end))
      in
      
      MyTable.transaction (IGroup.decay gid) update
	
  end in
  
  (* Update group columns *)
  let! () = ohm begin
    if diffs # columns = [] then return () else 
      Signals.on_upgrade_list_call
	(group # list, IGroup.decay gid, group # ins, diffs # columns) 
  end in
  
  return ()

let try_get context id =
  let! group = ohm_req_or (return None) $ _get id in
  return $ Some (_relation_of_data context id group)

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
  let update d =
    if d # grants = grants && d # manual = manual then `nothing, `keep else 
      let o = object
	method t      = `Group
	method ins    = d # ins
	method admins = d # admins
	method manual = manual
	method grants = grants
	method entity = d # entity
	method list   = d # list
	method fields = d # fields
	method propg  = d # propg
      end in
      `ok, `put o 
  in
  
  let! result = ohm $ MyTable.transaction
    (IGroup.decay gid) (MyTable.if_exists update)
  in
  
  match BatOption.default `nothing result with
    | `nothing -> return ()
    | `ok      -> Signals.on_update_call gid

module Get = struct
    
  let id       t = t.id    	 
    	  
  let is_admin t = t.data # admins

  let entity   t = t.data # entity 

  let manual   t = t.data # manual

  let instance t = t.data # ins

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
	id    = IGroup.Assert.list t.id ;
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
	id    = IGroup.Assert.write t.id ;
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
	id    = IGroup.Assert.admin t.id ;
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
      method ins    = d # ins
      method admins = d # admins
      method grants = d # grants
      method manual = d # manual
      method entity = d # entity
      method list   = d # list
      method fields = d # fields
      method propg  = propg
    end in

    MyTable.transaction (IGroup.decay id) (MyTable.update update) |> Run.map ignore

  (* Members in 'to_what' are added to 'what' automatically *)
  let add to_what what ctx = 
    let      what = IGroup.decay    what in 
    let   to_what = IGroup.decay to_what in 
    let! to_group = ohm_req_or (return ()) $ try_get ctx to_what in
    let! to_group = ohm_req_or (return ()) $ Can.admin to_group  in

    if List.mem what (to_group.data # propg) then return () else
      _set to_what (what :: to_group.data # propg)
   
  (* Members in 'from_what' are not added to 'what' anymore *)
  let rem from_what what = 
    let        what = IGroup.decay      what in 
    let   from_what = IGroup.decay from_what in      
    let! from_group = ohm_req_or (return ()) $ _get from_what in

    if List.mem what (from_group # propg) then  
      _set from_what (List.filter ((<>) what) from_group # propg)           
    else return ()

  let upgrade ~src ~dest action = 

    let src  = IGroup.decay src in
    let dest = IGroup.decay dest in 

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
    module Key = IGroup
    module Value = Fmt.Unit
    module Doc = Data
    module Design = Design
    let name   = "propg_from" 
    let map    = "if (doc.t == 'grup' && doc.propg) 
                    for (var k in doc.propg)
                      emit(doc.propg[k],null);" 
  end)

  let get gid context = 
    let  id    = IGroup.decay gid in 
    let! items = ohm $ InverseView.doc id in
    
    return $ List.map begin fun item -> 
      let id = IGroup.of_id (item # id) in 
      _relation_of_data context id (item # doc)
    end items

  let get_direct gid = 
    let! group = ohm_req_or (return []) $ _get gid in
    return (group # propg)

end

module Fields = struct

  let get t = 
    t.data # fields
    
  let set t fields = 
    (* Worst case, keep only 20 fields. *)
    let fields = BatList.take 20 fields in
    let update d = object
      method t      = `Group
      method ins    = d # ins
      method admins = d # admins
      method grants = d # grants
      method entity = d # entity
      method manual = d # manual
      method list   = d # list
      method fields = fields
      method propg  = d # propg
    end in
    
    MyTable.transaction (IGroup.decay t.id) (MyTable.update update)
    |> Run.map ignore

  let of_group id = 
    let! group = ohm_req_or (return []) $ _get id in
    return (group # fields)

  let complete id = 
    let rec aux id accum = 
      if List.exists (fun (x,_) -> x = id) accum then return accum else
	let! group = ohm_req_or (return accum) $ _get id in
	let  accum = (id, List.map (fun f -> f # name, f) group # fields) :: accum in
	List.fold_left (fun accum_m id -> accum_m |> Run.bind (aux id))
	  (return accum) (group # propg) 
    in
    aux (IGroup.decay id) []
      
end

(* Reacting to entity refreshes ------------------------------------------------------------- *)

let _refresh_token_grant = 

  let task = O.async # define "entity.refresh-group" IEntity.fmt 
    begin fun eid -> 
      
      let  finish = return () in 
      let! t      = ohm_req_or finish $ MEntity.bot_get eid in
      
      let  config       = MEntity.Get.config t in
      let! group_config = req_or finish (config # group) in
      let  gid          = MEntity.Get.group  t in
      
      let grants = 
	(match group_config # grant_tokens with 
	  | `yes -> true
	  | `no -> false
	) && not (MEntity.Get.inactive t) 
      in
      
      let manual = 
	(match group_config # validation with 
	  | `manual -> true
	  | `none   -> false)
      in
      
      let! () = ohm $ refresh (IGroup.Assert.bot gid) ~grants ~manual in
      
      finish
	
    end in
  
  fun (id : [`Bot] IEntity.id) -> task id

let () = 
  let! eid = Sig.listen MEntity.Signals.on_update in 
  _refresh_token_grant eid
  
let () = 
  let! eid, diffs = Sig.listen MEntity.Signals.on_upgrade in 
  let! t   = ohm_req_or (return ()) $ MEntity.bot_get eid in
  let  gid = MEntity.Get.group t in
  version_update gid diffs

let () = 
  let! iid, eid, gid, admin, diffs, _ = Sig.listen MEntity.Signals.on_bind_group in 
  let! _ = ohm $ create gid admin iid (IEntity.decay eid) diffs in
  return () 

