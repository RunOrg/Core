(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module MyDB = MModel.TalkDB

module Design = struct
  module Database = MyDB
  let name = "comment"
end
  
module Data = Fmt.Make(struct
  type json t = <
    t          : MType.t ;
    who        : IAvatar.t ;
    what       : string ;
    time       : float ;
    on         : IItem.t 
  > 
end)
  
module Tbl = CouchDB.Table(MyDB)(IComment)(Data)
  
include Data

module Signals = struct    
  let on_create_call, on_create = Sig.make (Run.list_iter identity)
  let on_delete_call, on_delete = Sig.make (Run.list_iter identity)
end

let () = 
  let! cid, comm = Sig.listen Signals.on_create in 
  let! iid = ohm_req_or (return ()) $ MAvatar.get_instance (comm # who) in
  let! uid = ohm_req_or (return ()) $ MAvatar.get_user (comm # who) in
  MAdminLog.log ~uid ~iid (MAdminLog.Payload.CommentCreate (IComment.decay cid))

let max_length = 50000
  
let create on who what =
  
  let comment : t = object
    method t     = `Comment
    method who   = IAvatar.decay who
    method on    = IItem.decay on
    method what  = clip max_length what
    method time  = Unix.gettimeofday ()
  end in
  
  let! id = ohm $ Tbl.create comment in 
   
  let  id = IComment.Assert.created id in	
  let! () = ohm $ Signals.on_create_call (id, comment) in 
  return (id, comment)
    
let remove cid = 
  let  cid     = IComment.decay cid in 
  let! comment = ohm_req_or (return ()) $ Tbl.get cid in
  let! ()      = ohm $ Signals.on_delete_call (cid, comment # on) in
  Tbl.delete cid 

module ByAvatar = CouchDB.DocView(struct
  module Key    = IAvatar
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "by_avatar"
  let map  = "if (doc.t == 'comm') emit(doc.who,null);"
end)

let _ = 
  let obliterate cid = remove cid in
  let on_obliterate_avatar (aid,_) = 
    let! list = ohm $ ByAvatar.doc aid in 
    let! _    = ohm $ Run.list_map (#id |- IComment.of_id |- obliterate) list in 
    return ()
  in
  Sig.listen MAvatar.Signals.on_obliterate on_obliterate_avatar
      
module AllView = CouchDB.DocView(struct
  module Key = IItem
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "all"
  let map  = "if (doc.t == 'comm') emit(doc.on,null);" 
end)
  
let all item = 
  
  let! items = ohm $ AllView.doc (IItem.decay item) in
  
  let visible_items = 
    List.map begin fun item ->
      (* Comments on visible items are visible *)
      IComment.Assert.read (IComment.of_id item # id), item # doc    
    end items
  in
  
  return visible_items
      
let get id = Tbl.get (IComment.decay id)

let item id = 
  let! comment = ohm_req_or (return None) $ get id in
  return $ Some (comment # on) 
    
let try_get item id = 

  let! comment = ohm_req_or (return None) $ get id in
  
  if comment # on = IItem.decay item then 
    (* Comments on visible items are visible *)
    return (Some (IComment.Assert.read id, comment))
  else
    return None  

module InterestedView = CouchDB.MapView(struct
  module Key    = IItem
  module Value  = IAvatar
  module Design = Design
  let name = "interested" 
  let map  = "if (doc.t == 'comm') emit(doc.on, doc.who)"
end)
  
let interested itid =
  let itid = IItem.decay itid in
  InterestedView.query ~startkey:itid ~endkey:itid ()
  |> Run.map (List.map (#value))
      
module Backdoor = struct
    
  module CountView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Int
    module Reduced = Fmt.Int
    module Design = Design
    let name = "backdoor-count"
    let map    = "if (doc.t == 'comm') emit(null,1);"
    let group  = true 
    let level  = None 
    let reduce = "return sum(values);"
  end)
    
  let count = 
    CountView.reduce_query () |> Run.map begin function
      | ( _, v ) :: _ -> v 
      | _ -> 0
    end
	
end
