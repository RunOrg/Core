(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Core    = MMail_core
module Plugins = MMail_plugins

(* List all the notifications of a given user in reverse chronological order *) 

module MineView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct type json t = (IUser.t * Date.t) end)
  module Value = Fmt.Unit
  module Doc = Core.Data
  module Design = Core.Design
  let name = "mine"
  let map = "if (!doc.dead && doc.item) emit([doc.uid,doc.time]);"
end)

let mine ?start ~count cuid = 

  let  uid = IUser.Deduce.current_is_self cuid in 
  let! u   = ohm_req_or (return ([],None)) (MUser.get uid) in

  let  uid' = IUser.Deduce.is_anyone cuid in 
  let  startkey = uid', BatOption.default Date.max start in
  let  endkey   = uid', Date.min in
  let  limit = count + 1 in
  let! list = ohm (MineView.doc_query ~startkey ~endkey ~limit ~descending:true ()) in
  let  list, next = OhmPaging.slice ~count list in 

  let! list = ohm (Run.list_filter begin fun item -> 
    let  mid    = IMail.of_id (item # id) in
    let  rotten = (let! () = ohm (Core.rot mid) in return None) in  
    let  t      = item # doc in 
    let! full   = ohm_req_or rotten (O.decay (Plugins.parse_item uid u mid t)) in
    return (Some full) 
  end list) in

  let  next = BatOption.map (#key |- snd) next in 

  return (list, next) 

(* Count the number of unread-OR-unsolved item notifications for a given user *) 

module UnreadOrUnsolvedView = CouchDB.ReduceView(struct
  module Key = IUser
  module Value = Fmt.Int
  module Design = Core.Design 
  let name = "unread_or_unsolved"
  let map  = "if (doc.dead) return;
              if (!doc.item) return;  
              if (doc.solved === null) {
                if (doc.clicked !== null) return;
                if (doc.zapped !== null) return;
              } 
              else if (doc.solved[0] === 'y') return;
              emit(doc.uid,1);"
  let reduce = "return sum(values);"
  let group = true
  let level = None
end)

let unread cuid = 
  let  uid   = IUser.Deduce.is_anyone cuid in 
  let! value = ohm_req_or (return 0) (UnreadOrUnsolvedView.reduce uid) in
  return value 

(* Count the number of untouched mails for a given user from a given instance. *)

module SilentView = CouchDB.ReduceView(struct
  module Key = Fmt.Make(struct type json t = (IUser.t * IInstance.t) end)
  module Value = Fmt.Int
  module Design = Core.Design 
  let name = "silent"
  let map  = "if (doc.dead) return;
              if (doc.sent === null) return;
              if (doc.blocked) return;
              if (doc.solved) return;
              if (doc.clicked) return;
              if (doc.opened) return;
              if (doc.zapped) return;
              if (doc.iid === null) return;
              emit([doc.uid,doc.iid],1);"
  let reduce = "return sum(values);"
  let group = true
  let level = None
end)

let silent uid iid = 
  let  iid = IInstance.decay iid and uid = IUser.decay uid in 
  let! value = ohm_req_or (return 0) (SilentView.reduce (uid,iid)) in
  return value 
