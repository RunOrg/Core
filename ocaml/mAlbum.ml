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
    iid   "ins" : IInstance.t ;
    owner       : [ `Event "ev" of IEvent.t ]
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

let _make actor id data = 
  let owner = Run.memo begin
    match data # owner with 
      | `Event  eid -> let nil = (fun _ -> return MAvatarStream.nobody) in
		       let! event = ohm_req_or (return nil) $ MEvent.get ~actor eid in
		       return (fun what -> MEvent.Satellite.access event (`Album what))
  end in
  {
    id    = id ;
    data  = data ;
    read  = ( let! f = ohm owner in 
	      let! read = ohm (f `Read) in
	      let! write = ohm (f `Write) in
	      let! manage = ohm (f `Manage) in
	      MAvatarStream.(is_in actor (union [read;write;manage])) ) ;
    write = ( let! f = ohm owner in 
	      let! write = ohm (f `Write) in
	      let! manage = ohm (f `Manage) in
	      MAvatarStream.(is_in actor (write + manage)) ) ;
    admin = ( let! f = ohm owner in 
	      let! manage = ohm (f `Manage) in
	      MAvatarStream.is_in actor manage ) ;
  }

(* Direct access ---------------------------------------------------------------------------- *)

let try_get actor id = 
  let! album_opt = ohm (Tbl.get (IAlbum.decay id)) in
  return (BatOption.map (_make actor id) album_opt)

let bot_get id = 
  let! data = ohm_req_or (return None) $ Tbl.get (IAlbum.decay id) in
  return $ Some {
    id    = id ;
    data  = data ;
    read  = return false ;
    write = return false ;
    admin = return false
  }

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
  let map = "emit(doc.owner[1]);"
end)

let get_or_create iid owner = 

  let id = IAlbumOwner.to_id owner in 

  let! found_opt = ohm (ByOwnerView.doc id |> Run.map Util.first) in

  match found_opt with 
    | Some item -> return (IAlbum.of_id (item # id), item # doc)
    | None -> (* Album missing, create one *)
      
      let doc = object
	method owner = IAlbumOwner.decay owner
	method iid   = IInstance.decay iid 
      end in 
      
      let! id = ohm $ Tbl.create doc in
      return (id, doc) 

let by_owner iid owner = 
  let! id, _ = ohm $ get_or_create iid owner in 
  return id 

let get_for_owner actor owner =   
  let  iid = MActor.instance actor in
  let! id, doc = ohm $ get_or_create iid owner in
  return (_make actor id doc)

let try_by_owner owner = 
  let id = IAlbumOwner.to_id owner in 
  let! found = ohm_req_or (return None) (ByOwnerView.doc id |> Run.map Util.first) in
  return $ Some (IAlbum.of_id (found # id))
