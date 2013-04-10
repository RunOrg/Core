(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Core    = MNotif_core
module Plugins = MNotif_plugins

(* List all the notifications of a given user in reverse chronological order *) 

module MineView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct type json t = (IUser.t * float) end)
  module Value = Fmt.Unit
  module Doc = Core.Data
  module Design = Core.Design
  let name = "mine"
  let map = "if (!doc.dead) emit([doc.uid,doc.time]);"
end)

let mine ?start ~count cuid = 

  let! now = ohmctx (#time) in
  let  uid = IUser.Deduce.is_anyone cuid in 
  let  startkey = uid, BatOption.default now start in
  let  endkey   = uid, 0.0 in
  let  limit = count + 1 in
  let! list = ohm (MineView.doc_query ~startkey ~endkey ~limit ~descending:true ()) in
  let  list, next = OhmPaging.slice ~count list in 

  let! list = ohm (Run.list_filter begin fun item -> 
    let  mid    = IMail.of_id (item # id) in
    let  rotten = (let! () = ohm (Core.rot mid) in return None) in  
    let  t      = item # doc in 
    let! full   = ohm_req_or rotten (O.decay (Plugins.parse mid t)) in
    return (Some full) 
  end list) in

  let  next = BatOption.map (#key |- snd) next in 

  return (list, next) 

(* Count the number of unread-OR-unsolved notifications for a given user *) 

module UnreadOrUnsolvedView = CouchDB.ReduceView(struct
  module Key = IUser
  module Value = Fmt.Int
  module Design = Core.Design 
  let name = "unread_or_unsolved"
  let map  = "if (!doc.dead && (doc.read === null || doc.solved === null && doc.solve !== null))
                emit(doc.uid,1);"
  let reduce = "return sum(values);"
  let group = false
  let level = None
end)

let unread cuid = 
  let  uid   = IUser.Deduce.is_anyone cuid in 
  let! value = ohm_req_or (return 0) (UnreadOrUnsolvedView.reduce uid) in
  return value 

