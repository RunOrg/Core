(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module E   = MEntity_core
module Can = MEntity_can
module Get = MEntity_get

type 'relation t = 'relation Can.t

module Active = Fmt.Make(struct
  type json t = (IInstance.t * MEntityKind.t)
end)

module ActiveView = CouchDB.DocView(struct
  module Key = Active
  module Value = Fmt.Unit
  module Doc = E.Format
  module Design = E.Design
  let name = "active"
  let map  = "if (!doc.c.archive && !doc.c.deleted) 
                emit([doc.c.instance,doc.c.kind],null);"
end)

module AllView = CouchDB.DocView(struct
  module Key = IInstance
  module Value = Fmt.Unit
  module Doc = E.Format
  module Design = E.Design
  let name = "all-active"
  let map  = "if (!doc.c.archive && !doc.c.deleted) 
                emit(doc.c.instance,null);"
end)

module PublicView = CouchDB.DocView(struct
  module Key = Active
  module Value = Fmt.Unit
  module Doc = E.Format
  module Design = E.Design
  let name = "public"
  let map  = "if (!doc.c.archive && doc.c.public && !doc.c.draft && !doc.c.deleted) 
                emit([doc.c.instance,doc.c.kind],null);"
end)

module WithMemberView = CouchDB.DocView(struct
  module Key = IInstance
  module Value = Fmt.Unit
  module Doc = E.Format
  module Design = E.Design
  let name = "with_member"
  let map  = "if (!doc.c.archive && !doc.c.draft && !doc.c.deleted && doc.c.config.group)
                emit(doc.c.instance,null)"
end)

module CalendarView = CouchDB.DocView(struct
  module Key   = Fmt.Make(struct
    type json t = (IInstance.t * string)
  end)
  module Value = Fmt.Unit
  module Doc = E.Format
  module Design = E.Design
  let name = "calendar"
  let map  = "if (!doc.c.archive && !doc.c.draft && !doc.c.deleted && doc.r.date)
                emit([doc.c.instance,doc.r.date],null)"
end)

let as_visible actor item = 
  Can.view $
    Can.make actor (IEntity.of_id (item # id)) (item # doc)

let as_administrable actor item = 
  Can.admin $
    Can.make actor (IEntity.of_id (item # id)) (item # doc)

let as_public item =
  Can.make_public (IEntity.of_id (item # id)) (item # doc)
    
let get_by_kind actor kind = 

  let iid = IInstance.decay (MActor.instance actor) in
  let! all = ohm $ ActiveView.doc (aid,kind) in
  Run.list_filter (as_visible actor) all

let get_administrable_by_kind actor kind = 
  
  let iid = IInstance.decay (MActor.instance actor) in
  let! all = ohm $ ActiveView.doc (iid,kind) in
  Run.list_filter (as_administrable actor) all

let get actor = 
  
  let iid = IInstance.decay (MActor.instance actor) in
  let! all = ohm $ AllView.doc iid in
  Run.list_filter (as_visible actor) all 

let get_public iid kind = 

  let! all = ohm $ PublicView.doc (iid,kind) in 
  return $ BatList.filter_map as_public all

let get_with_members actor =

  let   iid = IInstance.decay (MActor.instance actor) in
  let! list = ohm $ WithMemberView.doc iid in 
  Run.list_filter (as_visible ctx) list 

let get_future actor = 
 let  now = MFmt.date_of_float $ Unix.gettimeofday () in
 let  iid = IInstance.decay (MActor.instance actor) in
 let! list = ohm $ CalendarView.doc_query
   ~startkey:(iid,now)
   ~endkey:(iid,"99991231")
   ()
 in
 Run.list_filter (as_visible ctx) list

let get_public_future iid = 
  let! now = ohmctx (#time) in
  let  now = MFmt.date_of_float 0. (* now *) in 
  let! list = ohm $ CalendarView.doc_query
    ~startkey:(iid,now)
    ~endkey:(iid,"99991231")
    ()
  in
  return $ BatList.filter_map as_public list
