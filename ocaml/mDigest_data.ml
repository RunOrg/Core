(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Float = Fmt.Float
 
(* Dealing with items and item lists ------------------------------------------------------ *)

module Item = struct

  module T = struct
    type json t = {
      what "w" : IBroadcast.t ;
      from "f" : IInstance.t ;
      time "t" : Float.t ;
      last "l" : Float.t ;
      size "s" : int ;      
      via  "v" : IBroadcast.t option 
    }
  end 
  include T 
  include Fmt.Extend(T)

  let compare_time a b = compare b.time a.time
  let compare_id   a b = compare a.what b.what
end

module SourceMap = Map.Make(struct 
  type t = IInstance.t
  let compare = compare
end)

module RemoveSet = Set.Make(struct
  type t = IBroadcast.t
  let compare = compare
end)
  
let should_remove bids = 
  let set = List.fold_right RemoveSet.add bids RemoveSet.empty in 
  fun i -> 
    let bid = BatOption.default i.Item.what i.Item.via in
    RemoveSet.mem bid set

let relevance_sort seen items = 

  let list = List.sort Item.compare_time items in

  let _, list = List.fold_left begin fun (count,list) item -> 
    let c = 1 + try SourceMap.find item.Item.from count with Not_found -> 0 in
    let seen  = seen > item.Item.time in
    let count = SourceMap.add item.Item.from c count in 
    let list  = 
      if c > 4 then list else
	( (seen, c, item.Item.last -. item.Item.time) , item ) :: list
    in
    count, list
  end (SourceMap.empty,[]) list in 

  List.sort (fun (a,_) (b,_) -> compare a b) list |> List.map snd

let slice max seen items = 
  if List.length items > max then 
    relevance_sort seen items |> BatList.take max
  else
    items
  
(* Defining the actual container --------------------------------------------------------- *)

module T = struct
  type json t = {
    unviewed_since "uv" : Float.t ;
    unsent_since   "us" : Float.t ;
    unsent         "u"  : int ;
    send_delay     "n"  : Float.t ;
    contents       "c"  : Item.t list 
  }
end

module Data = struct
  include T
  include Fmt.Extend(T)
end

include Data

let max_items = 50 

let default () = 
  let time = Unix.gettimeofday () in
  {
    unviewed_since = 0.0 ;
    unsent_since   = time ;
    unsent         = 0 ;
    send_delay     = 24. *. 3600. ;
    contents       = []
  }

let set_delay delay t = 
  { t with send_delay = delay } 

let add_to items t = 
  let seen = max t.unviewed_since t.unsent_since in
  let contents = 
    ( items @ t.contents ) 
    |> BatList.sort_unique Item.compare_id 
    |> slice max_items seen 
  in
  let unsent = List.length $ List.filter (fun i -> i.Item.time > t.unsent_since) contents in
  { t with contents ; unsent }
  
let remove_from bids t =
  let contents = BatList.remove_if (should_remove bids) t.contents in 
  let unsent = List.length $ List.filter (fun i -> i.Item.time > t.unsent_since) contents in
  { t with contents ; unsent } 

let mark_seen time t = 
  if time < t.unviewed_since then None else
    if List.for_all (fun i -> i.Item.time < t.unviewed_since) t.contents then None else 
      Some { t with unviewed_since = time }

let mark_sent time t = 
  if time < t.unsent_since then None else
    let unsent = List.length $ List.filter (fun i -> i.Item.time > time) t.contents in
    Some { t with unsent ; unsent_since = time } 
 
(* Actual operations on the database ---------------------------------------------------- *)

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "digest" end) 
module MyTable = CouchDB.Table(MyDB)(IDigest)(Data)

module Design = struct
  module Database = MyDB
  let name = "digest"
end

let get_if_exists did = 
  MyTable.get (IDigest.decay did) 

let get did = 
  let! item = ohm_req_or (return $ default ()) $ get_if_exists did in
  return item 

let update_opt did func = 
  let! _ = ohm $ MyTable.transaction (IDigest.decay did) 
    (fun did -> let! digest = ohm $ get did in
		match func digest with 
		  | None -> return ((),`keep)
		  | Some digest -> return ((),`put digest))
  in
  return () 

let update did func = 
  update_opt did (fun digest -> Some (func digest)) 

let add_items did items = 
  update did (add_to items) 

let remove_items did bids = 
  update did (remove_from bids)

let mark_seen did =
  update_opt did (mark_seen (Unix.gettimeofday ()))

let update_opt did func = 
  MyTable.transaction (IDigest.decay did) 
    (fun did -> let! digest = ohm $ get did in
		match func digest with 
		  | None -> return (digest.unsent_since,`keep)
		  | Some digest' -> return (digest.unsent_since,`put digest'))

let mark_sent did = 
  update_opt did (mark_sent (Unix.gettimeofday ()))

let set_delay did delay = 
  update did (set_delay delay) 

type delay = float
let delay_day = 3600. *. 24. 
let delay_week = 7. *. delay_day 

(* Keep track of digests that can be sent. *)

module SendableView = CouchDB.DocView(struct
  module Key = Fmt.Float
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "sendable"
  let map  = "if (doc.u > 0) emit(doc.us + doc.n)"
end) 

let next_sendable () = 
  let now = Unix.gettimeofday () in
  let! list = ohm $ SendableView.doc_query ~endkey:now ~limit:1 () in
  match list with [] -> return None | h :: _ -> return $ Some (IDigest.of_id (h # id))
    
