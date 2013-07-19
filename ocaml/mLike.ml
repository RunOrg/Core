(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module MyDB = MModel.TalkDB

module Design = struct
  module Database = MyDB
  let name = "like"
end

module Data = Fmt.Make(struct
  type json t = <
    t    : MType.t ;
    who  : IAvatar.t ;
    what : Id.t list 
  > 
end)

module Tbl = CouchDB.Table(MyDB)(Id)(Data)
  
include Data

type 'relation what = [ `item    of 'relation IItem.id ]		  

module Signals = struct
  let on_like_call,   on_like   = Sig.make (Run.list_iter identity)
  let on_unlike_call, on_unlike = Sig.make (Run.list_iter identity)
end
  
module MLike = Fmt.Make(struct
  type json t = (Id.t * IAvatar.t)
end)

module LikeView = CouchDB.DocView(struct
  module Key = MLike
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "find"
  let map  = "if (doc.t == 'like') for (var k in doc.what) emit([doc.what[k],doc.who],null);"
end)
  
let id_of = function
  | `item i    -> IItem.to_id i
    
let liked = function
  | `item i    -> `item (IItem.Assert.liked i)
    
let likes who what = 
  let what = id_of what in
  LikeView.doc_query 
    ~startkey:(what,IAvatar.decay who) 
    ~endkey:(what,IAvatar.decay who)
    ~limit:1
    ()
  |> Run.map (function [] -> false | _ -> true)

let _find who what = 
  LikeView.doc (what, IAvatar.decay who) |> Run.map (List.map (#id))

module CountView = CouchDB.ReduceView(struct
  module Key = Id
  module Value = Fmt.Int
  module Reduced = Fmt.Int
  module Design = Design
  let name   = "count"
  let map    = "if (doc.t == 'like') for (var k in doc.what) emit(doc.what[k],1);"
  let reduce = "return sum(values);"
  let group  = true
  let level  = None
end)

let count what = 
  let! total_opt = ohm $ CountView.reduce (id_of what) in
  return (BatOption.default 0 total_opt) 
      
module FreeView = CouchDB.DocView(struct
  module Key = IAvatar
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "free"
  let map  = "if (doc.t == 'like' && doc.what.length < 20) emit(doc.who,null);" 
end)
  
let _free who = 
  FreeView.doc (IAvatar.decay who)
  |> Run.map Util.first 
  |> Run.map (BatOption.map (#id))
      
let like who what = 
  let! likes = ohm $ likes who what in

  if not likes then begin    
    
    let who = IAvatar.decay who in
    let transform opt = (), `put (object
      method t = `Like
      method who  = who
      method what = match opt with 
	| None     -> [id_of what]
	| Some obj ->  id_of what :: obj # what
    end) in
    
    let! id = ohm (_free who |> Run.map begin function
      | Some id -> id
      | None -> Id.gen () 
    end) in
	
    let! write = ohm $ Tbl.transact id (transform %> return) in
    
    Signals.on_like_call (who, liked what)

  end else

    return ()

  
let unlike who what = 
  
  let who = IAvatar.decay who in
  
  let remove obj = object
    method t    = `Like
    method who  = who
    method what = BatList.remove_all (obj # what) (id_of what) 
  end in
  
  let remove_from id = Tbl.update id remove in 
  
  let! () = ohm begin 
    _find who (id_of what) 
    |> Run.bind (Run.list_map remove_from)  
    |> Run.map ignore
  end in
  
  Signals.on_unlike_call (who, liked what)

module InterestedView = CouchDB.MapView(struct
  module Key    = IItem
  module Value  = IAvatar
  module Design = Design
  let name = "interested" 
  let map  = "if (doc.t == 'like') for (var k in doc.l) emit(doc.l[k], doc.who);" 
end)
  
let interested itid =
  let itid = IItem.decay itid in
  InterestedView.query ~startkey:itid ~endkey:itid ()
  |> Run.map (List.map (#value))

module ByAvatarView = CouchDB.DocView(struct
  module Key    = IAvatar
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "by_avatar"
  let map  = "if (doc.t == 'like') emit(doc.who,null);"
end)

let _ =
  let obliterate lid = 
    let! like = ohm_req_or (return ()) $ Tbl.get lid in
    let aid = like # who in 
    let! _    = ohm $ Run.list_map begin fun what -> 
      let! () = ohm $ Signals.on_unlike_call
	(aid,liked (`item (IItem.of_id what)))
      in
      return ()
    end (like # what) in
    Tbl.delete lid 
  in
  let on_obliterate_avatar (aid,_) = 
    let! list = ohm $ ByAvatarView.doc aid in 
    let! _ = ohm $ Run.list_map (#id %> obliterate) list in 
    return ()
  in
  Sig.listen MAvatar.Signals.on_obliterate on_obliterate_avatar

module Backdoor = struct
    
  module CountView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Int
    module Reduced = Fmt.Int
    module Design = Design
    let name = "backdoor-count"
    let map = "if (doc.t == 'like') emit(null,doc.what.length);" 
    let group  = true 
    let level  = None 
    let reduce = "return sum(values);" 
  end)
    
  let count () = 
    CountView.reduce_query () |> Run.map begin function
      | ( _, v ) :: _ -> v 
      | _ -> 0
    end
	
end    


