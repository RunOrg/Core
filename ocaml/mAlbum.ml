(* © 2012 MRunOrg *)

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
    t : MType.t ;
    ins : IInstance.t ;
    owner : [`entity "e" of IEntity.t]
  >
end)

module MyTable = CouchDB.Table(MyDB)(IAlbum)(Data)

type 'relation t = 
    {
      id    : 'relation IAlbum.id ;
      data  : Data.t ;
      read  : bool O.run ;
      write : bool O.run ;
      admin : bool O.run ;
    }

let _make context id data = 
  let owner = Run.memo begin
    match data # owner with 
      | `entity  eid -> begin
	let nil = (fun _ -> `Nobody) in
	let! entity = ohm_req_or (return nil) $ MEntity.try_get context eid in
	return (fun what -> MEntity.Satellite.access entity (`Album what))
      end
  end in
  {
    id    = id ;
    data  = data ;
    read  = ( let! f = ohm owner in MAccess.test context [ f `Read ; f `Write ; f `Manage ] ) ;
    write = ( let! f = ohm owner in MAccess.test context [           f `Write ; f `Manage ] ) ;
    admin = ( let! f = ohm owner in MAccess.test context [                      f `Manage ] ) ;
  }

(* Direct access ---------------------------------------------------------------------------- *)

let try_get ctx id = 
  let! album_opt = ohm (MyTable.get (IAlbum.decay id)) in
  return (BatOption.map (_make ctx id) album_opt)

module Get = struct

  let id t = t.id

  let entity t = match t.data # owner with 
    | `entity eid -> Some eid

  let instance t = t.data # ins

  let write_instance t = 
    (* I can upload, since I can write to the album *)
    t.data # ins |> IInstance.Assert.upload

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

(* MAccess by entity ------------------------------------------------------------------------- *)

module ByEntityView = CouchDB.DocView(struct
  module Key = IEntity
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "by_entity"
  let map = "if (doc.t == 'albm' && doc.owner) emit(doc.owner[1]);"
end)

let get_for_entity ctx eid =   

  let  eid = IEntity.decay eid in 
  let! found_opt = ohm (ByEntityView.doc eid |> Run.map Util.first) in

  let create_if_missing =  
    match found_opt with 
      | Some item -> return (IAlbum.of_id (item # id), item # doc)
      | None -> (* MAlbum missing, create one *)

	let id = IAlbum.gen () in
	let doc = object
	  method t     = `Album
	  method owner = `entity eid
	  method ins   = IIsIn.instance (ctx # isin) |> IInstance.decay 
	end in 

	let! _ = ohm (MyTable.transaction id (MyTable.insert doc)) in
	return (id, doc) 
  in
  
  let! id, doc = ohm create_if_missing in

  return (_make ctx id doc)
