(* © 2012 MRunOrg *)

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
  module PAvatar = IAvatar
  module PItem   = IItem
  module PFeed   = IFeed
  module Float   = Fmt.Float
  type json t = <
    t          : MType.t ;
    who        : PAvatar.t ;
    what       : string ;
    time       : Float.t ;
    on         : PItem.t 
  > 
end)
  
module MyTable = CouchDB.Table(MyDB)(IComment)(Data)
  
include Data

module Signals = struct    
  let on_create_call, on_create = Sig.make (Run.list_iter identity)
  let on_delete_call, on_delete = Sig.make (Run.list_iter identity)
end

let max_length = 1000
  
let create on who what =
  
  let id = IComment.gen () in    
  
  let insert : t = object
    method t     = `Comment
    method who   = IAvatar.decay who
    method on    = IItem.decay on
    method what  = clip max_length what
    method time  = Unix.gettimeofday ()
  end in
  
  let! result = ohm $ MyTable.put id insert in
  
  match result with 
    | `collision -> return None
    | `ok -> let id = IComment.Assert.created id in	
	     let! () = ohm $ Signals.on_create_call (id, insert) in 
             return $ Some id

let remove cid = 
  let  cid     = IComment.decay cid in 
  let! comment = ohm_req_or (return ()) $ MyTable.get cid in
  let! ()      = ohm $ Signals.on_delete_call (cid, comment # on) in
  let! _       = ohm $ MyTable.transaction cid MyTable.remove in
  return ()

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

module InFeed = Fmt.Make(struct
  type json t = IFeed.t * IItem.t
end)
      
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
      
let get id = MyTable.get (IComment.decay id)
    
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
