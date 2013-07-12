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
    own       : [ `Event of IEvent.t 
		| `Discussion of IDiscussion.t 
		| `Newsletter of INewsletter.t
		]
  > 
end)
  
module Tbl = CouchDB.Table(MyDB)(IFeed)(Data)
  
type 'relation t = 
    {
      id     : 'relation IFeed.id ;
      data   : Data.t ;
      access : ([`Read|`Write|`Manage] -> MAvatarStream.t O.run) O.run ;
      read   : bool O.run ;
      write  : bool O.run ;
      admin  : bool O.run ;
    }

let nil _ = return MAvatarStream.nobody
			  
let _access iid = function 
  | `Event eid -> let! event = ohm_req_or (return nil) $ MEvent.get eid in
		  return (fun what -> MEvent.Satellite.access event (`Wall what))
  | `Discussion did -> let! discussion = ohm_req_or (return nil) $ MDiscussion.get did in 
		       return (fun what -> MDiscussion.Satellite.access discussion (`Wall what)) 
  | `Newsletter nlid -> let! nletter = ohm_req_or (return nil) $ MNewsletter.get nlid in 
			return (fun what -> MNewsletter.Satellite.access nletter (`Wall what)) 
    
let _make actor id (data:Data.t) = 
  let owner = Run.memo (_access (data # iid) (data # own)) in
  {
    id     = id ;
    data   = data ;
    access = owner ;
    read   = ( let! f = ohm owner in 
	       let! read = ohm (f `Read) in
	       let! write = ohm (f `Write) in
	       let! manage = ohm (f `Manage) in
	       MAvatarStream.(is_in actor (union [read;write;manage])) ) ;
    write  = ( let! f = ohm owner in 
	       let! write = ohm (f `Write) in
	       let! manage = ohm (f `Manage) in
	       MAvatarStream.(is_in actor (write + manage)) ) ;
    admin  = ( let! f = ohm owner in 
	       let! manage = ohm (f `Manage) in
	       MAvatarStream.is_in actor manage ) ;
  }

(* Direct access ---------------------------------------------------------------------------- *)

let try_get actor id = 
  let! feed_opt = ohm (Tbl.get (IFeed.decay id)) in
  return (BatOption.map (_make actor id) feed_opt)

module Get = struct

  let id t = t.id

  let owner_of_data feed = 
    feed # own

  let owner feed = 
    owner_of_data feed.data

  let owner_by_id fid = 
    let id = IFeed.decay fid in 
    Tbl.get id |> Run.map (BatOption.map owner_of_data) 
	
  let instance t = 
    t.data # iid

  let read_access t = 
    let! f = ohm t.access in
    let! read = ohm (f `Read) in
    let! write = ohm (f `Write) in
    let! manage = ohm (f `Manage) in
    return (MAvatarStream.union [ read ; write ; manage ])

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

let get_or_create iid owner =   

  let  id = IFeedOwner.to_id owner in
  let! found_opt = ohm (ByOwnerView.doc id |> Run.map Util.first) in
  match found_opt with 
    | Some item -> return (IFeed.of_id (item # id), item # doc)
    | None -> (* Feed missing, create one *)
      
      let doc = object
	method t     = `Feed
	method own   = IFeedOwner.decay owner 
	method iid   = IInstance.decay iid
      end in 
      
      let! id = ohm $ Tbl.create doc in
      return (id, doc) 
	
let get_for_owner actor owner =
  let  iid = MActor.instance actor in 
  let! id, doc = ohm $ get_or_create iid owner in 
  return (_make actor id doc)

let by_owner iid owner = 
  let! id, _ = ohm $ get_or_create iid owner in 
  return id

let try_by_owner owner = 
  let  id = IFeedOwner.to_id owner in
  let! found = ohm_req_or (return None) $ (ByOwnerView.doc id |> Run.map Util.first) in
  return $ Some (IFeed.of_id (found # id))

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

