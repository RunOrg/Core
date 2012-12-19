(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

(* General definitions ---------------------------------------------------------------------- *)

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "album" end)
module Design = struct
  module Database = MyDB
  let name = "album"
end

module Data = Fmt.Make(struct
  type json t = <
    t           : MType.t ;
    iid   "ins" : IInstance.t ;
    owner       : [ `Entity "e" of IEntity.t | `Event "ev" of IEvent.t ]
  >
end)

module Tbl = CouchDB.Table(MyDB)(IAlbum)(Data)

type 'relation t = 
    {
      id    : 'relation IAlbum.id ;
      data  : Data.t ;
      read  : bool O.run ;
      write : bool O.run ;
      admin : bool O.run ;
    }

let _make access id data = 
  let owner = Run.memo begin
    match data # owner with 
      | `Entity eid -> let nil = (fun _ -> `Nobody) in
		       let! entity = ohm_req_or (return nil) $ MEntity.try_get access eid in
		       return (fun what -> MEntity.Satellite.access entity (`Album what))
      | `Event  eid -> let nil = (fun _ -> `Nobody) in
		       let! event = ohm_req_or (return nil) $ MEvent.get ~access eid in
		       return (fun what -> MEvent.Satellite.access event (`Album what))
  end in
  {
    id    = id ;
    data  = data ;
    read  = ( let! f = ohm owner in MAccess.test access [ f `Read ; f `Write ; f `Manage ] ) ;
    write = ( let! f = ohm owner in MAccess.test access [           f `Write ; f `Manage ] ) ;
    admin = ( let! f = ohm owner in MAccess.test access [                      f `Manage ] ) ;
  }

(* Direct access ---------------------------------------------------------------------------- *)

let try_get ctx id = 
  let! album_opt = ohm (Tbl.get (IAlbum.decay id)) in
  return (BatOption.map (_make ctx id) album_opt)

module Get = struct

  let id t = t.id

  let owner t = t.data # owner

  let instance t = t.data # iid

  let write_instance t = 
    (* I can upload, since I can write to the album *)
    t.data # iid |> IInstance.Assert.upload

end

module Can = struct

  let write t = 
    let! allowed = ohm t.write in
    return (
      if allowed then Some {
	id    = IAlbum.Assert.write t.id ; (* Proven above *)
	data  = t.data ;
	write = return true ;
	read  = return true ;
	admin = t.admin
      }
      else None
    )

  let read t = 
    let! allowed = ohm t.read in
    return (
      if allowed then Some {
	id    = IAlbum.Assert.read t.id ; (* Proven above *)
	data  = t.data ;
	write = t.write ;
	read  = return true ;
	admin = t.admin 
      } 
      else None
    )

  let admin t = 
    let! allowed = ohm t.admin in
    return (
      if allowed then Some {
	id    = IAlbum.Assert.admin t.id ; (* Proven above *)
	data  = t.data ;
	write = return true ;
	read  = return true ;
	admin = return true 
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
  let name = "by_owner"
  let map = "if (doc.t == 'albm' && doc.owner) emit(doc.owner[1]);"
end)

let get_for_owner ctx owner =   

  let  id = match owner with 
    | `Entity eid -> IEntity.to_id (IEntity.decay eid) 
    | `Event  eid -> IEvent.to_id  (IEvent.decay  eid)
  in 

  let owner = match owner with 
    | `Entity eid -> `Entity (IEntity.decay eid)
    | `Event  eid -> `Event  (IEvent.decay  eid) 
  in

  let! found_opt = ohm (ByOwnerView.doc id |> Run.map Util.first) in

  let create_if_missing =  
    match found_opt with 
      | Some item -> return (IAlbum.of_id (item # id), item # doc)
      | None -> (* Mlbum missing, create one *)

	let doc = object
	  method t     = `Album
	  method owner = owner
	  method iid   = IIsIn.instance (ctx # isin) |> IInstance.decay 
	end in 

	let! id = ohm $ Tbl.create doc in
	return (id, doc) 
  in
  
  let! id, doc = ohm create_if_missing in

  return (_make ctx id doc)

let get_for_event ctx eid = get_for_owner ctx (`Event eid)
let get_for_entity ctx eid = get_for_owner ctx (`Entity eid) 

(* {{MIGRATION}} *)

let () = 
  let! eid, evid, _ = Sig.listen MEntity.on_migrate in 
  let! found = ohm_req_or (return ()) $ (ByOwnerView.doc (IEntity.to_id eid) |> Run.map Util.first) in
  let  doc, id = found # doc, found # id in  
  if doc # owner <> `Event evid then

    let changed = object
      method t     = doc # t
      method iid   = doc # iid
      method owner = `Event evid
    end in 

    let! _ = ohm $ Tbl.set (IAlbum.of_id id) changed in
    return () 
    
  else return () 
