(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module E = MEntity_core
module MyTable = E.Table

module Can       = MEntity_can
module Get       = MEntity_get 
module Data      = MEntity_data
module Access    = MEntity_access
module All       = MEntity_all
module Satellite = MEntity_satellite
module Signals   = MEntity_signals

let access = MEntity_can.access

type 'relation t = 'relation MEntity_can.t

(* Attempt to load an entity --------------------------------------------------------------- *)

let bot_get (id : [`Bot] IEntity.id) = 
  MyTable.get (IEntity.decay id) |> Run.map (BatOption.map (MEntity_can.make_full id))

let naked_get id = 
  MyTable.get (IEntity.decay id) |> Run.map (BatOption.map (MEntity_can.make_naked id)) 
  
let try_get context id = 
  let isin = context # myself in
  let instance = IInstance.decay (IIsIn.instance isin) in
  let! entity = ohm_req_or (return None) $ MyTable.get (IEntity.decay id) in
  if instance  <> entity.E.instance then 
    (* MEntity is in another castle^Winstance *)
    return None
  else
    return $ Some (MEntity_can.make context id entity) 

(* Various refresh routines --------------------------------------------------------------- *)

let () = 
  let! v = Sig.listen E.Store.Signals.version_create in
  Signals.on_update_call (IEntity.Assert.bot (E.Store.version_object v))
	      
(* Updating entities ----------------------------------------------------------------------- *)

exception UnknownTemplate of ITemplate.t
    
let try_update t ~status ~name ~data isin = 

  let  mod_id = Id.gen () in
  let! avatar = ohm $ MAvatar.get isin in

  let  avatar = IAvatar.decay avatar in
  let  who    = `user (mod_id, avatar) in

  let e = Can.data t in

  let diffs = 
    (* Set the status only if not already correct *)
    if status = `Draft && e.E.draft ||
       status = `Active && not e.E.draft && e.E.deleted = None ||
       status = `Delete && e.E.deleted <> None
    then []
    else [ `Status (match status with 
      | `Delete -> `Delete avatar
      | `Draft  -> `Draft
      | `Active -> `Active
    ) ]
  in  

  let! () = ohm $
    if diffs = [] then return () else    
      E.Store.update
	~id:(IEntity.decay (Get.id t)) 
	~diffs
	~info:(MUpdateInfo.info ~who)
	() |> Run.map ignore
  in

  MEntity_data.update ~id:(Get.id t) ~who ~name ~data ()
  
(* Creating entities ----------------------------------------------------------------------- *)

let _create ?(admin=false) ?name template iid creator_opt = 

  let! id, gid = ohm (
    match name with 
      | None      -> return (IEntity.gen (), IGroup.gen ()) 
      | Some name -> let namer = MPreConfigNamer.load iid in 
		     let! eid = ohm $ MPreConfigNamer.entity name namer in
		     let! gid = ohm $ MPreConfigNamer.group  name namer in
		     return (eid,gid)
  ) in

  (* We are creating this entity *)
  let eid = IEntity.Assert.created id in

  (* And the matching group *)
  let gid = IGroup.Assert.bot gid in  

  let who = 
    match creator_opt with None -> `preconfig | Some avatar -> 
      `user (Id.gen (), IAvatar.decay avatar)
  in

  let! instance = ohm $ MInstance.get iid in 

  let! () = ohm $ Signals.on_bind_group_call (iid,eid,gid,admin,template,creator_opt) in

  let! data = ohm $ MEntity_data.create ~id:eid ~who () in
  
  let init = E.Init.({
    archive  = false ;
    draft    = false ;
    public   = false ;
    admin    = `Admin ;
    view     = `Token ;
    group    = IGroup.decay gid ;
    config   = MEntityConfig.default ;
    kind     = PreConfig_Template.kind template ;
    template = ITemplate.decay template ;
    instance = IInstance.decay iid ;
    deleted  = None ;
    creator  = BatOption.map IAvatar.decay creator_opt 
  }) in
      
  let! _ = ohm $ E.Store.create
    ~id:(IEntity.decay eid) ~info:(MUpdateInfo.info ~who) ~init 
    ~diffs:[ ] ()
  in
	
  return eid
 
let create template isin =
  let  iid     = IIsIn.instance isin in
  let! avatar  = ohm $ MAvatar.get isin in
  _create template (IInstance.decay iid) (Some avatar)

let bot_create iid diff = 
  _create ~name:(diff # name) (diff # template) (IInstance.decay iid) None

let set_grants ctx eids = 

  let! self = ohm $ ctx # self in 
  let  info = MUpdateInfo.info ~who:(`user (Id.gen (), IAvatar.decay self)) in

  let  iid     = IInstance.decay (IIsIn.instance (ctx # myself)) in 
  let! current = ohm $ All.get_granting ctx in 

  let eids    = List.map IEntity.decay eids in 
  let current = List.map (Get.id |- IEntity.decay) current in 

  let to_remove = List.filter (fun eid -> not (List.mem eid eids)) current in 
  let to_add    = List.filter (fun eid -> not (List.mem eid current)) eids in 

  let set_grant grant id = 
    let  diffs    = [ `Config [`Group_GrantTokens (if grant then `Yes else `No)] ] in
    let! previous = ohm_req_or (return ()) $ E.Table.get id in
    if previous.E.instance <> iid then return () else  
      let! _ = ohm $ E.Store.update ~id ~info ~diffs () in
      return ()
  in

  let! _ = ohm $ Run.list_iter (set_grant false) to_remove in 
  let! _ = ohm $ Run.list_iter (set_grant true)  to_add in 

  return ()

(* Attempt to grab a public entity if it is public. ---------------------------------------- *)

let get_if_public eid = 
  let  id = IEntity.decay eid in 
  let! entity = ohm_req_or (return None) $ MyTable.get id in
  if entity.E.draft then return None else
    if not (entity.E.public) then return None else
      (* Can be seen, because it's public *)
      let eid = IEntity.Assert.view eid in
      return $ Some (MEntity_can.make_visible eid entity)
      
(* Create the administrators entity based on a vertical. ---------------------------------- *)

let _ = 

  let! iid = Sig.listen MInstance.Signals.on_create in
  
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in
  let! creator  = ohm $ MAvatar.become_contact iid (instance # usr) in
  
  (* Act as the creator... *)
  let creator = IAvatar.Assert.is_self creator in
  
  let! _        = ohm $
    _create ~admin:true ~name:"admin" ITemplate.admin (IInstance.decay iid) (Some creator)
  in
  
  return ()  

(* List the dates of real entities *)

module RealEntityDateView = CouchDB.MapView(struct
  module Key    = IInstance
  module Value  = Fmt.Make(struct type json t = string option end)
  module Design = E.Design 
  let name = "real-entity"
  let map  = "if (doc.c.creator && doc.c.kind == 'Event') emit(doc.c.instance,doc.r.end_date || doc.r.date)"
end)

let get_last_real_event_date iid = 
  let! list  = ohm $ RealEntityDateView.by_key (IInstance.decay iid) in 
  let  dates = List.map (#value) list in 
  
  if List.mem None dates then return (Some None) else
    match List.sort (fun a b -> compare b a) dates with 
      | [] -> return None
      | h :: _ -> return $ Some h 

module Backdoor = struct

  module CountView = CouchDB.ReduceView(struct
    module Key = MEntityKind
    module Value = Fmt.Int
    module Reduced = Fmt.Int
    module Design = E.Design
    let name   = "backdoor-count" 
    let map    = "emit(doc.c.kind,1);" 
    let group  = true
    let level  = None
    let reduce = "return sum(values);" 
  end)

  let count =
    CountView.reduce_query ()

end
