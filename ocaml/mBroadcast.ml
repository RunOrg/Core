(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Types = MBroadcast_types

include Types

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "broadcast" end) 
module MyTable = CouchDB.Table(MyDB)(IBroadcast)(Item)

module Design = struct
  module Database = MyDB
  let name = "broadcast"
end

module Signals = struct
  let on_create_call, on_create = Sig.make (Run.list_iter identity)
end

(* Extracting the public representation from the private representation --------------------- *)

let extract_forward (bid,item) = object
  method id     = bid
  method from   = item.Item.from
  method author = item.Item.author
  method time   = item.Item.time
end

let rec extract bid ?forward item =
  if item.Item.delete <> None then return None
  else match item.Item.kind with 
      
    | `Forward f -> let! item' = ohm_req_or (return None) $ MyTable.get (f # real) in
		    if forward = None then 
		      let forward = (bid,item) in
		      extract (f # real) ~forward item'
		    else
		      (* Whoops, "real" does not point to the real content... *)
		      return None

    | `Content c -> let obj = object
                      method id       = bid 
		      method from     = item.Item.from
		      method author   = item.Item.author
		      method time     = item.Item.time
		      method forwards = c # forwards
		      method forward  = BatOption.map extract_forward forward
		      method content  = c # what
                    end in
		    return (Some obj)

let rec get_real ?(recurse=false) bid = 
  let! item = ohm_req_or (return None) $ MyTable.get bid in 
  if item.Item.delete <> None then return None else 
    match item.Item.kind with 
      | `Forward f -> if recurse then return None else get_real (f # real) 
      | `Content _ -> return (Some bid) 

(* Post a brand new broadcast --------------------------------------------------------------- *)

let generic_post iid aid time content = 

  let item = Item.({
    from   = IInstance.decay iid ;
    author = BatOption.map IAvatar.decay aid ;
    time   ;
    kind   = `Content (object
      method what     = content
      method forwards = 0
    end) ;
    delete = None
  }) in

  let bid = IBroadcast.gen () in
  
  let! _  = ohm $ MyTable.transaction bid (MyTable.insert item) in
  let! () = ohm $ Signals.on_create_call bid in 

  return bid 

let post iid aid content = 
  generic_post iid (Some aid) (Unix.gettimeofday ()) content

(* Post a brand new RSS broadcast ----------------------------------------------------------- *)

module RssUniqueDB = CouchDB.Convenience.Database(struct let db = O.db "broadcast-rss-u" end)
module RssUnique = OhmCouchUnique.Make(RssUniqueDB)

let rss_unique_key iid link = 
  IInstance.to_string iid ^ Netencoding.Url.encode link

let rss_not_seen_yet iid link = 
  let  id  = Id.gen () in
  let! id' = ohm $ RssUnique.lock (rss_unique_key iid link) id in
  return (id = id')

let _ = 
  Sig.listen MPolling.RSS.Signals.update begin fun (rss_id,content) -> 
    let! list = ohm $ MInstance.Profile.by_rss rss_id in
    if list = [] then return false else 
      let! _ = ohm $ Run.list_map begin fun iid -> 
	Run.list_map begin fun item -> 
	  let link = item.MPolling.RSS.link in
	  Util.log "Processing item [%s]" link ;
	  let! can_post = ohm $ rss_not_seen_yet iid link in 
	  if can_post then 
	    let content = `RSS MPolling.RSS.(object
	      method body  = item.body
	      method title = item.title
	      method link  = link
	    end) in
	    let! _ = ohm $ generic_post iid None item.MPolling.RSS.time content in
	    return () 
	  else
	    return ()
	end content
      end list in 
      return true
  end

(* Keeping track of forwards. -------------------------------------------------------------- *)

module ForwardsCountView = CouchDB.ReduceView(struct
  module Key = IBroadcast
  module Value = Fmt.Int
  module Design = Design
  let name = "count-forwards"
  let map  = "if (!doc.d && doc.k[0] == 'f') emit(doc.k[1].r,1)"
  let reduce = "return sum(values)" 
  let group = true
  let level = None
end)

let count_forwards bid = 
  let! value = ohm $ ForwardsCountView.reduce bid in 
  return $ BatOption.default 0 value 

let refresh_forwards bid = 

  let update bid = 
    let  whoops = return ((),`keep) in
    let! item  = ohm_req_or whoops $ MyTable.get bid in 
    if item.Item.delete <> None then whoops else 
      match item.Item.kind with 
	| `Forward _ -> whoops
	| `Content c -> let! count = ohm $ count_forwards bid in
			let  item' = Item.({ item with kind = `Content (object
			  method what = c # what
			  method forwards = count
			end) }) in
			return ((),`put item')
  in 

  let! _ = ohm $ MyTable.transaction bid update in

  return () 

let refresh_forwards_later = 
  let task = O.async # define "broadcast-refresh-forwards" IBroadcast.fmt refresh_forwards in
  fun bid -> task bid

(* Perform an actual forwarding ------------------------------------------------------------ *)

let forward iid aid from_bid = 
  let! real_bid = ohm_req_or (return ()) $ get_real from_bid in   

  let item = Item.({
    from   = IInstance.decay iid ;
    author = Some (IAvatar.decay aid) ;
    time   = Unix.gettimeofday () ;
    kind   = `Forward (object
      method from = from_bid
      method real = real_bid
    end) ;
    delete = None
  }) in

  let bid = IBroadcast.gen () in
  
  let! _  = ohm $ MyTable.transaction bid (MyTable.insert item) in
  let! _  = ohm $ refresh_forwards_later bid in
  let! () = ohm $ Signals.on_create_call bid in 
  return ()

(* Extract an item for display -------------------------------------------------------------- *)

let get bid = 
  let! item = ohm_req_or (return None) $ MyTable.get bid in 
  extract bid item 

(* Display available forwards for a given item ---------------------------------------------- *)

module ForwardsView = CouchDB.DocView(struct
  module Key    = IBroadcast
  module Value  = Fmt.Int
  module Doc    = Item
  module Design = Design
  let name = "forwards"
  let map  = "if (!doc.d && doc.k[0] == 'f') emit(doc.k[1].r,1)"
end)

let forwards bid = 

  let! raw_list = ohm $ ForwardsView.doc bid in 
  let  extract i = extract_forward (IBroadcast.of_id (i#id),(i#doc)) in
  let  list = List.map extract raw_list in

  return list 

(* Display a short summary (less bandwidth usage) ------------------------------------------- *)

module SummaryView = CouchDB.MapView(struct
  module Key    = IBroadcast
  module Value  = Fmt.Make(struct
    type json t = float * string
  end)
  module Design = Design
  let name = "summary"
  let map  = "if (!doc.d && doc.k[0] == 'c') { 
                if (doc.k[1].w[0] == 'p') 
                  emit(doc._id,[doc.t,doc.k[1].w[1].t])
                if (doc.k[1].w[0] == 'r') 
                  emit(doc._id,[doc.t,doc.k[1].w[1].t])
              }"
end)

let get_summary bid = 
  let! list = ohm $ SummaryView.by_key bid in 
  match list with [] -> return None | h :: _ -> return $ Some (h # value) 

(* Display the latest values for a given instance. ------------------------------------------ *)

module ByInstanceView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct
    type json t = (IInstance.t * float)
  end)
  module Value  = Fmt.Unit
  module Doc    = Item
  module Design = Design 
  let name = "by-instance"
  let map  = "if (!doc.d) emit([doc.f,doc.t])"
end)

let latest ?start ~count iid = 

  let! now = ohmctx (#time) in

  let start = BatOption.default (now +. 3600.) start in   
  let startkey = iid, start and endkey = iid, 0.0 in
  
  let limit = count + 1 in

  let! raw_list = ohm $ ByInstanceView.doc_query 
    ~startkey ~endkey ~descending:true ~limit ()
  in

  let  extract i = 
    let! extract = ohm $ extract (IBroadcast.of_id (i#id)) (i#doc) in
    return (snd (i#key),extract)
  in

  let! list = ohm $ Run.list_map extract raw_list in

  let list, next = OhmPaging.slice ~count list in 
  
  return (BatList.filter_map snd list, BatOption.map fst next) 

let previous iid time = 
  
  let startkey = iid, ( time -. 1.0 ) and endkey = iid, 0.0 in
  let! list = ohm $ ByInstanceView.doc_query 
    ~startkey ~endkey ~descending:true ~limit:1 ()
  in

  match list with [] -> return None | h :: _ -> return $ Some (h # doc).Item.time

(* Display the latest values for a given instance. ------------------------------------------ *)

module IdByInstanceView = CouchDB.MapView(struct
  module Key = Fmt.Make(struct
    type json t = (IInstance.t * float)
  end)
  module Value  = Fmt.Unit
  module Design = Design 
  let name = "by-instance"
  let map  = "if (!doc.d) emit([doc.f,doc.t])"
end)

let recent_ids iid ~count = 

  let startkey = iid, Unix.gettimeofday () +. 3600. and endkey = iid, 0.0 in
  let! raw_list = ohm $ IdByInstanceView.query 
    ~startkey ~endkey ~descending:true ~limit:count ()
  in

  let  extract i = IBroadcast.of_id (i#id) in
  return $ List.map extract raw_list

(* Count the posts by a given instance --------------------------------------------------- *)

module CountByInstanceView = CouchDB.ReduceView(struct
  module Key    = IInstance
  module Value  = Fmt.Int
  module Design = Design 
  let name = "count-by-instance"
  let map  = "if (!doc.d) emit(doc.f,1)"
  let reduce = "return sum(values)"
  let group  = true
  let level  = None
end)

let count iid = 
  let! count = ohm_req_or (return 0) $ CountByInstanceView.reduce iid in 
  return count

(* Remove a broadcasted item . -------------------------------------------------------------- *)

let remove iid aid bid = 

  let iid = IInstance.decay iid and aid = IAvatar.decay aid in 
  let delete = Some (Unix.gettimeofday (), aid ) in

  let remove bid = 
    let whoops = return (None,`keep) in
    let! item = ohm_req_or whoops $ MyTable.get bid in
    if item.Item.delete <> None || item.Item.from <> iid then whoops else
      match item.Item.kind with 
	| `Content _ -> return (None, `put Item.({ item with delete }))
	| `Forward f -> return (Some f, `put Item.({ item with delete }))
  in
  
  let! f = ohm_req_or (return ()) $ MyTable.transaction bid remove in
  let! _ = ohm $ refresh_forwards_later (f # real) in  

  return ()

module Backdoor = struct

  module PostCountView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Int
    module Design = Design 
    let name = "backdoor-posts"
    let map  = "if (!doc.d && doc.k[0] == 'c') emit(null,1)"
    let reduce = "return sum(values)"
    let group  = true
    let level  = None
  end)

  let posts = 
    let! int_opt = ohm $ PostCountView.reduce () in
    return $ BatOption.default 0 int_opt

  module ForwardCountView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Int
    module Design = Design 
    let name = "backdoor-forwards"
    let map  = "if (!doc.d && doc.k[0] == 'f') emit(null,1)"
    let reduce = "return sum(values)"
    let group  = true
    let level  = None
  end)

  let forwards = 
    let! int_opt = ohm $ ForwardCountView.reduce () in
    return $ BatOption.default 0 int_opt

end
