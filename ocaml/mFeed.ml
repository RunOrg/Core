(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module MyDB = MModel.TalkDB

module Design = struct
  module Database = MyDB
  let name = "feed"
end
  
module Data = Fmt.Make(struct
  type json t = <
    t         : MType.t ;
    iid "ins" : IInstance.t ;
    own       : [`Entity "of_entity" of IEntity.t | `Event of IEvent.t ] option 
  > 
end)
  
module Tbl = CouchDB.Table(MyDB)(IFeed)(Data)
  
type 'relation t = 
    {
      id     : 'relation IFeed.id ;
      data   : Data.t ;
      access : ([`Read|`Write|`Manage] -> MAccess.t) O.run ;
      read   : bool O.run ;
      write  : bool O.run ;
      admin  : bool O.run ;
    }

let _access iid = function 
  | Some (`Entity eid) -> let nil = (fun _ -> `Nobody) in
			  let! entity = ohm_req_or (return nil) $ MEntity.naked_get eid in
			  return (fun what -> MEntity.Satellite.access entity (`Wall what))
  | Some (`Event eid) -> let nil = (fun _ -> `Nobody) in
			  let! event = ohm_req_or (return nil) $ MEvent.get eid in
			  return (fun what -> MEvent.Satellite.access event (`Wall what))
  | None -> let! wall_post = ohm $ MInstanceAccess.wall_post iid in  
	    return (function
	      | `Read   -> `Token
	      | `Write  -> (match wall_post with `Admin -> `Admin | `Member -> `Token)
	      | `Manage -> `Admin)
    
let _make context id (data:Data.t) = 
  let owner = Run.memo (_access (data # iid) (data # own)) in
  {
    id     = id ;
    data   = data ;
    access = owner ;
    read   = ( let! f = ohm owner in MAccess.test context [ f `Read ; f `Write ; f `Manage ] ) ;
    write  = ( let! f = ohm owner in MAccess.test context [           f `Write ; f `Manage ] ) ;
    admin  = ( let! f = ohm owner in MAccess.test context [                      f `Manage ] ) ;
  }

(* Direct access ---------------------------------------------------------------------------- *)

let try_get ctx id = 
  let! feed_opt = ohm (Tbl.get (IFeed.decay id)) in
  return (BatOption.map (_make ctx id) feed_opt)

module Get = struct

  let id t = t.id

  let owner_of_data feed = 	
    match feed # own with
      | None               -> `Instance (feed # iid)
      | Some (`Entity eid) -> `Entity eid      
      | Some (`Event  eid) -> `Event  eid

  let owner feed = owner_of_data feed.data

  let owner_by_id fid = 
    let id = IFeed.decay fid in 
    Tbl.get id |> Run.map (BatOption.map owner_of_data) 
	
  let instance t = t.data # iid

  let notified t = 
    let! reader = ohm t.access in
    return [ reader `Read ; reader `Write ; reader `Manage ] 

  let read_access t = 
    let! reader = ohm t.access in
    return [ reader `Read ; reader `Write ; reader `Manage ] 

end

module Can = struct

  let write t = 
    let! allowed = ohm t.write in
    return (
      if allowed then Some {
	id     = IFeed.Assert.write t.id ; (* Proven above *)
	data   = t.data ;
	access = t.access ;
	write  = return true ;
	read   = return true ;
	admin  = t.admin
      }
      else None
    )

  let read t = 
    let! allowed = ohm t.read in
    return (
      if allowed then Some {
	id     = IFeed.Assert.read t.id ; (* Proven above *)
	data   = t.data ;
	write  = t.write ;
	access = t.access ;
	read   = return true ;
	admin  = t.admin 
      } 
      else None
    )

  let admin t = 
    let! allowed = ohm t.admin in
    return (
      if allowed then Some {
	id     = IFeed.Assert.admin t.id ; (* Proven above *)
	data   = t.data ;
	access = t.access ;
	write  = return true ;
	read   = return true ;
	admin  = return true 
      } 
      else None
    )

end

(* Access by entity ------------------------------------------------------------------------- *)

module ByOwnerView = CouchDB.DocView(struct
  module Key = Id
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "by_entity"
  let map = "if (doc.t == 'feed' &&  doc.own) emit(doc.own[1]);
             if (doc.t == 'feed' && !doc.own) emit(doc.ins);"
end)

let get_for_owner ctx own =   

  let  id = match own with 
    | Some (`Entity  eid) -> IEntity.to_id eid   
    | Some (`Event   eid) -> IEvent.to_id  eid
    | None                -> IIsIn.instance (ctx # isin) |> IInstance.to_id
  in 

  let! found_opt = ohm (ByOwnerView.doc id |> Run.map Util.first) in

  let! id, doc = ohm begin
    match found_opt with 
      | Some item -> return (IFeed.of_id (item # id), item # doc)
      | None -> (* Feed missing, create one *)

	let doc = object
	  method t     = `Feed
	  method own   = own
	  method iid   = IIsIn.instance (ctx # isin) |> IInstance.decay 
	end in 

	let! id = ohm $ Tbl.create doc in
	return (id, doc) 
  end in

  return (_make ctx id doc)

let get_for_entity ctx eid = 
  get_for_owner ctx (Some (`Entity (IEntity.decay eid)))

let get_for_event ctx eid = 
  get_for_owner ctx (Some (`Event (IEvent.decay eid)))

let get_for_instance ctx = 
  get_for_owner ctx None

let bot_get fid = 
  let! feed = ohm_req_or (return None) $ Tbl.get (IFeed.decay fid) in
  let owner = Run.memo (_access (feed # iid) (feed # own)) in
  return $ Some {
    id     = fid ;
    data   = feed ;
    access = owner ; 
    write  = return false ;
    read   = return false ;
    admin  = return false
  } 

let bot_find iid own = 
  let  id = match own with 
    | Some (`Entity  eid) -> IEntity.to_id eid   
    | Some (`Event   eid) -> IEvent.to_id eid 
    | None                -> IInstance.to_id iid
  in 

  let! found_opt = ohm (ByOwnerView.doc id |> Run.map Util.first) in

  let! id = ohm begin
    match found_opt with 
      | Some item -> return $ IFeed.of_id (item # id)
      | None -> (* Feed missing, create one *)
	
	let doc = object
	  method t     = `Feed
	  method own   = own
	  method iid   = IInstance.decay iid
	end in 
	
	Tbl.create doc 	
  end in 

  return $ IFeed.Assert.bot id (* This is a bot-only access. *)

