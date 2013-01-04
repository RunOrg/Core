(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module E = MEntity_core
module Tbl = E.Table

module Can       = MEntity_can
module Get       = MEntity_get 
module Data      = MEntity_data
module All       = MEntity_all
module Satellite = MEntity_satellite
module Signals   = MEntity_signals
module Migrate   = MEntity_migrate

type 'relation t = 'relation MEntity_can.t

(* Attempt to load an entity --------------------------------------------------------------- *)

let bot_get (id : [`Bot] IEntity.id) = 
  Tbl.get (IEntity.decay id) |> Run.map (BatOption.map (MEntity_can.make_full id))

let naked_get id = 
  Tbl.get (IEntity.decay id) |> Run.map (BatOption.map (MEntity_can.make_naked id)) 
  
let try_get actor id = 
  let instance = IInstance.decay (MActor.instance actor) in
  let! entity = ohm_req_or (return None) $ Tbl.get (IEntity.decay id) in
  if instance  <> entity.E.instance then 
    (* MEntity is in another castle^Winstance *)
    return None
  else
    return $ Some (MEntity_can.make actor id entity) 

(* Various refresh routines --------------------------------------------------------------- *)

let () = 
  let! v = Sig.listen E.Store.Signals.version_create in
  Signals.on_update_call (IEntity.Assert.bot (E.Store.version_object v))

(* Updating entities ----------------------------------------------------------------------- *)
    
let delete self t = 

  let! _ = ohm $ E.Store.update
    ~id:(IEntity.decay (Get.id t)) 
    ~diffs:[ `Status (`Delete (IAvatar.decay self)) ]
    ~info:(MUpdateInfo.self self)
    ()
  in

  return () 
	     
(* Updating entities ----------------------------------------------------------------------- *)
    
let try_update self t ~draft ~name ~data ~view = 

  let upinfo = MUpdateInfo.self self in
  let who    = upinfo.MUpdateInfo.who in 
  
  let e = Can.data t in

  let draft = 
    (* Set the status only if not already correct *)
    if draft && e.E.draft ||
       not draft && not e.E.draft && e.E.deleted = None
    then []
    else [ `Status (if draft then `Draft else `Active) ] 
  in  

  let access = if Get.real_access t = view then [] else [ `Access view ] in

  let diffs = draft @ access in 

  let! _ = ohm $
    if diffs = [] then return None else    
      E.Store.update
	~id:(IEntity.decay (Get.id t)) 
	~diffs
	~info:(MUpdateInfo.self self)
	()
  in

  MEntity_data.update ~id:(Get.id t) ~who ~name ~data ()
  
let set_picture self t pic = 

  let upinfo = MUpdateInfo.self self in
  let who    = upinfo.MUpdateInfo.who in 
  
  let! key = req_or (return ()) $ PreConfig_Template.Meaning.picture (Get.template t) in

  let pic = match pic with None -> Json.Null | Some pic -> IFile.to_json $ IFile.decay pic in
  let data = [ key, pic ] in

  MEntity_data.update ~id:(Get.id t) ~who ~data ()
    
let set_admins self t access =
  
  let! _ = ohm $ E.Store.update 
    ~id:(IEntity.decay (Get.id t))
    ~diffs:[ `Admin access ]
    ~info:(MUpdateInfo.self self) 
    ()
  in

  return () 

(* Creating entities ----------------------------------------------------------------------- *)

let _create ?pcname ?name ?pic ?access template iid creator = 

  let! id, gid = ohm (
    match pcname with 
      | None        -> return (IEntity.gen (), IGroup.gen ()) 
      | Some pcname -> let namer = MPreConfigNamer.load iid in 
		       let! eid = ohm $ MPreConfigNamer.entity pcname namer in
		       let! gid = ohm $ MPreConfigNamer.group  pcname namer in
		       return (eid,gid)
  ) in

  (* We are creating this entity *)
  let eid = IEntity.Assert.created id in

  (* And the matching group *)
  let gid = IGroup.Assert.bot gid in  

  let who = `user (Id.gen (), IAvatar.decay creator) in

  let! instance = ohm $ MInstance.get iid in 

  let! () = ohm $ Signals.on_bind_group_call (iid,eid,gid,template,creator) in

  let data = match pic with None -> None | Some pic -> 
    match PreConfig_Template.Meaning.picture template with None -> None | Some key -> 
      Some [ key, pic ]    
  in

  let draft = PreConfig_Template.kind template = `Event in

  let diffs = match access with 
    | None   -> []
    | Some a -> [ `Access a ]
  in

  let! data = ohm $ MEntity_data.create ~id:eid ~who ?name ?data () in

  let kind = PreConfig_Template.kind template in  

  let init = E.Init.({
    archive  = false ;
    draft    ;
    public   = false ;
    admin    = if kind = `Group then `Nobody else `List [ IAvatar.decay creator ] ;
    view     = `Token ;
    group    = IGroup.decay gid ;
    config   = MEntityConfig.default ;
    kind     ;
    template = ITemplate.decay template ;
    instance = IInstance.decay iid ;
    deleted  = None ;
    creator  = Some (IAvatar.decay creator) 
  }) in
      
  let! _ = ohm $ E.Store.create
    ~id:(IEntity.decay eid) ~info:(MUpdateInfo.info ~who) ~init 
    ~diffs ()
  in
	
  return eid
 
let create self ~name ?pic ~iid ?access template =
  let pic = BatOption.map (IFile.decay |- IFile.to_json) pic in
  let iid = IInstance.decay iid in 

  (* Perform the actual creation *)
  let! eid = ohm $ _create template ~name ?pic ?access iid self in

  (* Log that we've created this *)
  let! () = ohm begin 
    let! uid = ohm_req_or (return ()) $ MAvatar.get_user self in 
    let  kind = match PreConfig_Template.kind template with 
      | `Event -> `Event | `Forum -> `Forum | _ -> `Group in 
    MAdminLog.log ~uid ~iid (MAdminLog.Payload.EntityCreate (kind,IEntity.decay eid))
  end in 

  return eid 

(* Attempt to grab a public entity if it is public. ---------------------------------------- *)

let get_if_public eid = 
  let  id = IEntity.decay eid in 
  let! entity = ohm_req_or (return None) $ Tbl.get id in
  if entity.E.draft then return None else
    if not (entity.E.public) then return None else
      (* Can be seen, because it's public *)
      let eid = IEntity.Assert.view eid in
      return $ Some (MEntity_can.make_visible eid entity)

(* Collect the instance of an entity -------------------------------------------------------- *)

let instance eid = 
  Tbl.using (IEntity.decay eid) (fun e -> e.E.instance) 

(* Admin group entity name ------------------------------------------------------------------ *)

let admin_group_name iid = 
  let  pcnamer = MPreConfigNamer.load iid in 
  let  default = `label `EntityAdminName in
  let! eid     = ohm $ MPreConfigNamer.entity "admin" pcnamer in 
  let! entity  = ohm_req_or (return default) $ naked_get eid in 
  return (BatOption.default default (Get.name entity))   

let is_admin e = 
  if Get.kind e <> `Group then return false else
    let  pcnamer = MPreConfigNamer.load (Get.instance e) in 
    let! eid     = ohm $ MPreConfigNamer.entity "admin" pcnamer in 
    return (eid = IEntity.decay (Get.id e))
      
let is_all_members e = 
  if Get.kind e <> `Group then return false else
    let  pcnamer = MPreConfigNamer.load (Get.instance e) in 
    let! eid     = ohm $ MPreConfigNamer.entity "members" pcnamer in 
    return (eid = IEntity.decay (Get.id e))
      
(* Create the initial entities. ------------------------------------------------------------- *)

let create_initial = 
  let task = O.async # define "create-initial-entities" Fmt.(IInstance.fmt * IAvatar.fmt) 
    begin fun (iid,aid) -> 
    
      let! instance = ohm_req_or (return ()) $ MInstance.get iid in 
      let  created = PreConfig_Vertical.create (instance # ver) in
      
      Run.list_iter begin fun (tmpl,label) -> 
	let! _ = ohm $ _create ~name:(Some (`label label)) tmpl iid aid in
	return ()
      end created
	
    end in 
  fun iid aid -> task (IInstance.decay iid, aid)

let _ = 

  let! iid = Sig.listen MInstance.Signals.on_create in
  
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in
  
  let! aid = ohm $ MAvatar.become_admin iid (instance # usr) in

  (* Act as the creator... *)
  let creator = IAvatar.Assert.is_self aid in
  
  let! () = ohm $ create_initial iid creator in 

  let! _ = ohm $ _create 
    ~pcname:"admin"  
    ~name:(Some (`label `EntityAdminName))
    ~access:`Private
    ITemplate.admin (IInstance.decay iid) creator
  in

  let! _ = ohm $ _create 
    ~pcname:"members" 
    ~name:(Some (`label `EntityMembersName))
    ITemplate.members (IInstance.decay iid) creator
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

(* {{MIGRATION}} *)

let on_migrate_call, on_migrate = Sig.make (Run.list_exists identity)

let migrate_all = Async.Convenience.foreach O.async "migrate-discussion-entities"
  IEntity.fmt (Tbl.all_ids ~count:10)
  (fun eid ->
    let! entity = ohm_req_or (return ()) $ Tbl.get eid in
    if entity.E.kind = `Event || entity.E.deleted <> None then return () else begin
      
      (* Migrate groups and forums to discussions *)
      let time = Unix.gettimeofday () in
      let! self = req_or (return ()) $ BatOption.map IAvatar.Assert.is_self entity.E.creator in
      let  iid  = entity.E.instance in
      let  gid  = entity.E.group in
      let  kind = entity.E.kind in 
      let! name = ohm_req_or (return ()) $ Run.opt_map TextOrAdlib.to_string entity.E.name in
      
      let! ok = ohm $ on_migrate_call (eid, iid, gid, self, kind, name) in
      let  () = if ok then Util.log "Migrate group - %.3fs - %s %S" (Unix.gettimeofday () -. time)
	(IEntity.to_string eid) name in
      return ()
	
    end)

(* Perform entity migration *)
let () = O.put (migrate_all ())

