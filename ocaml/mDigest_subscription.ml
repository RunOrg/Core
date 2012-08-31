(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Unique = struct

  module MyDB = CouchDB.Convenience.Database(struct let db = O.db "digest-sbs-u" end) 
  module MyUnique = OhmCouchUnique.Make(MyDB)
    
  let key did iid = IDigest.to_string did ^ "-" ^ IInstance.to_string iid

  let get did iid = MyUnique.get (key did iid) |> Run.map IDigestSbs.of_id  
  let get_if_exists did iid = 
    MyUnique.get_if_exists (key did iid) |> Run.map (BatOption.map IDigestSbs.of_id) 

end

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "digest-sbs" end)
module Design = struct
  module Database = MyDB
  let name = "digest"
end

module Sbs = struct
  module T = struct
    type json t = {
      did         : IDigest.t ;
      iid         : IInstance.t ;
      block   "b" : bool ;
      direct  "d" : bool ;
      through "t" : IInstance.t list 
    }
  end
  include T
  include Fmt.Extend(T)
end

module Signals = struct

  let on_follow_call,   on_follow   = Sig.make (Run.list_iter identity)
  let on_unfollow_call, on_unfollow = Sig.make (Run.list_iter identity)

end

module Tbl = CouchDB.Table(MyDB)(IDigestSbs)(Sbs)

let default did iid = 
  Sbs.({ did ; iid ; block = false ; direct = false ; through = [] })

(* Determine if following *)

let sbs_contains sbs = Sbs.( not sbs.block && (sbs.direct || sbs.through <> []) )

let follows did iid = 
  let! dsid = ohm_req_or (return false) $ Unique.get_if_exists did iid in
  let! sbs  = ohm_req_or (return false) $ Tbl.get dsid in
  return $ sbs_contains sbs

(* Change the object outside the database *)

let sbs_subscribe   sbs = 
  Sbs.({ sbs with block = false ; direct = true })
				   
let sbs_unsubscribe sbs = 
  Sbs.(if sbs.direct && sbs.through = [] then { sbs with direct = false } else { sbs with block = true })

let sbs_add_through iid sbs = 
  let iid = IInstance.decay iid in
  Sbs.({ sbs with through = BatList.sort_unique compare (iid :: sbs.through) })

let sbs_remove_through iid sbs = 
  let iid = IInstance.decay iid in
  Sbs.({ sbs with through = BatList.remove sbs.through iid })

(* Change the object in the database : generic functions *)

let update func did iid sbs_opt = 
  let  sbs     = BatOption.default (default did iid) sbs_opt in
  let  sbs'    = func sbs in  
  let  sbs_c   = sbs_contains sbs  in 
  let  sbs_c'  = sbs_contains sbs' in
  return begin
    ( if sbs_c = sbs_c' then None else Some sbs_c' ),
    ( if sbs = sbs' then `keep else `put sbs' )
  end

let transaction func did iid = 
  let  did  = IDigest.decay did and iid = IInstance.decay iid in
  let! dsid = ohm $ Unique.get did iid in
  let! change_opt = ohm $ Tbl.transact dsid (update func did iid) in
  
  match change_opt with 
    | None -> return () 
    | Some follow -> if follow then Signals.on_follow_call (did,iid) else Signals.on_unfollow_call (did,iid)

let subscribe did iid = transaction sbs_subscribe did iid
let unsubscribe did iid = transaction sbs_unsubscribe did iid
let add_through did iid ~through = transaction (sbs_add_through through) did iid
let remove_through did iid ~through = transaction (sbs_remove_through through) did iid

(* Count followers *) 

module FollowersView = CouchDB.ReduceView(struct
  module Key = IInstance
  module Value = Fmt.Int
  module Design = Design 
  let name = "count-followers"
  let map  = "if (!doc.b && (doc.t.length || doc.d)) emit(doc.iid,1)"
  let reduce = "return sum(values)"
  let group  = true
  let level  = None
end)

let count_followers iid = 
  let! int_opt = ohm $ FollowersView.reduce (IInstance.decay iid) in 
  return $ BatOption.default 0 int_opt

(* List followers *)

module ListFollowersView = CouchDB.MapView(struct
  module Key = Fmt.Make(struct
    type json t = (IInstance.t * IDigest.t)
  end)
  module Value = Fmt.Unit
  module Design = Design 
  let name = "list-followers"
  let map  = "if (!doc.b && (doc.t.length || doc.d)) emit([doc.iid,doc.did])"
end)

let followers ?start ~count iid = 

  let limit = count + 1 
  and startkey = iid, BatOption.default (IDigest.of_id Id.smallest) start 
  and endkey   = iid, IDigest.of_id Id.largest in
  
  let! list = ohm $ ListFollowersView.query ~startkey ~endkey ~limit () in
  
  return $ OhmPaging.slice ~count (List.map (#key |- snd) list)  

(* Multiple removal *)

module ThroughView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct
    type json t = (IDigest.t * IInstance.t)
  end)
  module Value = Fmt.Unit
  module Doc = Sbs
  module Design = Design
  let name = "through"
  let map  = "for (var i = 0; i < doc.t.length; ++i) emit([doc.did,doc.t[i]])"
end)

let remove_all_through did iid = 
  let  did  = IDigest.decay did and iid = IInstance.decay iid in 
  let! list = ohm $ ThroughView.doc (did,iid) in
  let  ids  = List.map (fun i -> (i # doc).Sbs.iid) list in
  let! _    = ohm $ Run.list_map (fun iid' -> remove_through did iid' ~through:iid) ids in
  return () 

module Backdoor = struct
    
  module CountView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Make(struct
      type json t = int * int * int * int
    end) 
    module Design = Design
    let name = "backdoor-count"
    let map  = "if (doc.b) return emit(null,[0,0,0,1]);
                if (doc.d) return emit(null,[1,0,0,0]);
                for (var i = 0; i < doc.t.length; ++i) 
                  if (doc.t[i] == doc.iid) return emit(null,[0,1,0,0]);
                if (doc.t.length > 0) emit(null,[0,0,1,0]);"
    let reduce = "var r = [0,0,0,0];
                  for (var k = 0; k < 4; ++k) 
                    for (var i = 0; i < values.length; ++i)  
                      r[k] += values[i][k];
                  return r;"
    let group = true
    let level = None
  end)

  let zero = object 
    method direct = 0
    method member = 0
    method through = 0
    method blocked = 0
  end 

  let count = 
    let! direct, member, through, blocked = ohm_req_or (return zero) $ CountView.reduce () in
    return (object
      method direct  = direct
      method member  = member
      method through = through
      method blocked = blocked
    end)

end
