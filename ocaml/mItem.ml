(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

open MItem_common
open MItem_db

module Payload  = MItem_payload
module Data     = MItem_data
module Signals  = MItem_signals
module React    = MItem_react
module Remove   = MItem_remove
module Create   = MItem_create
module Backdoor = MItem_backdoor

include MItem_types
include MItem_create

let () = 
  let! item = Sig.listen Signals.on_post in 
  let  iid = item # iid in
  let! aid = req_or (return ()) $ author_by_payload (item # payload) in
  let! uid = ohm_req_or (return ()) $ MAvatar.get_user aid in
  MAdminLog.log ~uid ~iid (MAdminLog.Payload.ItemCreate (IItem.decay (item # id)))

type 'a source = 'a MItem_common.source

module PrevNextView = CouchDB.MapView(struct

  module Key = Fmt.Make(struct
    module Float = Fmt.Float
    type json t = (Id.t * Float.t)
  end)

  module Value  = Fmt.Unit
  module Design = Design

  let name = "prev_next"
  let map  = "if (!doc.del && !doc.d) emit([doc.w[1],doc.t])" 

end)
		
let prev_next item =
 
  let where = to_id (item # where) in

  let startid  = IItem.to_id (IItem.decay (item # id)) in
  let startkey = (where,item # time) in
  
  let! before = ohm $
    PrevNextView.query ~startkey ~startid ~limit:5 ~descending:true ()
  in

  let! after  = ohm $
    PrevNextView.query ~startkey ~startid ~limit:5 ~descending:false ()
  in

  let get_first pred list = 
    try Some (List.find pred list) with Not_found -> None
  in

  let prev = 
    get_first (fun x -> 
      x # id <> startid  
      && snd (x # key) <= snd startkey
      && fst (x # key)  = where
    ) before
  in

  let next = 
    get_first (fun x -> 
      x # id <> startid 
      && snd (x # key) >= snd startkey
      && fst (x # key)  = where
    ) after
  in

  let to_id x = IItem.of_id (x # id) in
  
  return (BatOption.map to_id prev, BatOption.map to_id next)

module InListView = CouchDB.DocView(struct

  module Key = Fmt.Make(struct
    module Float = Fmt.Float
    type json t = (Id.t * Float.t)
  end)

  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design

  let name = "all"
  let map  = "if (!doc.d && !doc.del) emit([doc.w[1],doc.t]);" 

end)

let extract self data = 
  let itid = IItem.of_id (data # id) in 
  item_of_data itid ?self (data # doc)

let list ?self source ~count start =

  let where = to_id source in 

  let! now  = ohm (Run.context |> Run.map (#time)) in

  let startkey = where, BatOption.default now start in
  let endkey   = where, 0.0 in

  let! list = ohm $ InListView.doc_query
      ~descending:true
      ~limit:(count+1)
      ~startkey
      ~endkey
      ()
  in 
    
  let list, next = OhmPaging.slice list ~count in
  let next = BatOption.map (#key |- snd) next in
  let list = List.map (extract self) list in 

  return (list,next)

module CountInListView = CouchDB.ReduceView(struct

  module Key    = Id
  module Value  = Fmt.Int
  module Doc    = Data
  module Design = Design

  let name = "count"
  let map  = "if (!doc.d && !doc.del) emit(doc.w[1],1);"
  let reduce = "return sum(values);" 
  let group = true
  let level = None

end)

let count source = 
  let where = to_id source in 
  let! result = ohm_req_or (return 0) $ CountInListView.reduce where in 
  return result

module LastInListView = CouchDB.DocView(struct

  module Key = Fmt.Make(struct
    module Float = Fmt.Float
    type json t = (Id.t * Float.t)
  end)

  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design

  let name = "all"
  let map  = "if (!doc.d && !doc.del) emit([doc.w[1],doc.t]);" 
end)

let last ?self source = 

  let where   = to_id source in 
  
  let startkey = (Id.next where, 0.0) in
  
  let! list = ohm $ LastInListView.doc_query ~startkey ~descending:true ~limit:1 () in
  
  match list with [] -> return None | h :: _ ->
    let id, _ = h # key in 
    if id <> where then return None else 
      return $ Some (extract self h)

let exists source = 
  let! last = ohm $ last source in 
  return (last <> None)

let interested itid = 
  let! likers     = ohm $ MLike.interested itid in 
  let! commenters = ohm $ MComment.interested itid in
  let! item       = ohm_req_or (return []) $ Tbl.get (IItem.decay itid) in
  let  list = likers @ commenters in
  let  list = match MItem_data.author item with None -> list | Some aid -> aid :: list in 
  return $ BatList.sort_unique compare list 

let iid itid = 
  let! data = ohm_req_or (return None) $ Tbl.get (IItem.decay itid) in
  return $ Some (data # iid) 

let author itid = 
  let! data = ohm_req_or (return None) $ Tbl.get (IItem.decay itid) in
  return $ MItem_data.author data

let try_get context item = 

  let self = context # self in
  let who  = Some (IAvatar.decay self) in 
  let item = IItem.decay item in

  let! data = ohm_req_or (return None) $ Tbl.get item in
  
  let is_visible_in = function 
    | `feed feed     -> 
      let! feed = ohm_req_or (return false) $ MFeed.try_get context feed in
      let! feed = ohm_req_or (return false) $ MFeed.Can.read feed in
      return true
    | `album album   -> 
      let! album = ohm_req_or (return false) $ MAlbum.try_get context album in
      let! album = ohm_req_or (return false) $ MAlbum.Can.read album in 
      return true
    | `folder folder -> 
      let! folder = ohm_req_or (return false) $ MFolder.try_get context folder in
      let! folder = ohm_req_or (return false) $ MFolder.Can.read folder in 
      return true
  in
  
  if data # del || data # delayed then return None else 
    let! visible = ohm $ is_visible_in (data # where) in 
    if visible || who <> None && who = MItem_data.author data then 
      return $ Some (item_of_data item ~self data) 
    else 
      return None

module NewsView = CouchDB.DocView(struct

  module Key = Fmt.Make(struct
    type json t = (IInstance.t * float)
  end)

  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design

  let name = "news"
  let map  = "if (!doc.d && !doc.del && doc.w[0] == 'w') emit([doc.iid,doc.t]);" 

end)

let month = 3600. *. 24. *. 30.

let news ?self ?since access iid = 

  let  iid = IInstance.decay iid in 
  let! now = ohmctx (#time) in
  let  startkey = (iid, now) in
  let  endkey   = (iid, BatOption.default (now -. month) since) in
  let  access   = Util.memoize (fun fid -> Run.memo (access fid)) in

  let! list = ohm $ NewsView.doc_query ~startkey ~endkey ~descending:true ~limit:200 () in

  let! list = ohm (Run.list_filter begin fun item ->
    let doc = item # doc in 
    match doc # where with `album _ | `folder _ -> return None | `feed fid ->
      let! fid  = ohm_req_or (return None) (access fid) in
      let  itid = IItem.of_id (item # id) in
      let  item = item_of_data ?self itid doc in 
      return (Some item) 
  end list) in

  return list
