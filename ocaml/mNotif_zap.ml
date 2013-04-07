(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Core = MNotif_core

module ZapUnreadView = CouchDB.DocView(struct
  module Key = IUser
  module Value = Fmt.Unit
  module Doc = Core.Data
  module Design = Core.Design
  let name = "zap_unread"
  let map = "if (!doc.dead && doc.read === null) emit(doc.uid);"
end)

let task_zap, def_zap = O.async # declare "notif-zap" IUser.fmt
let unread uid =
  let! now  = ohmctx (#time) in
  let! nids = ohm (ZapUnreadView.doc_query ~startkey:uid ~endkey:uid ~endinclusive:true ~limit:5 ()) in
  if nids = [] then return () else
    let! () = ohm (Run.list_iter (#id |- INotif.of_id |- Core.zap) nids) in
    O.decay (task_zap uid)

let () = def_zap unread

