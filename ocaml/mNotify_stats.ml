(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Payload = MNotify_payload
module Store   = MNotify_store

let see now d = 
  if d.Store.seen = None then Store.({ d with seen = Some now }) else d

let from_mail nid = 
  let! now = ohmctx (#time) in
  Store.Tbl.update nid 
     (fun d -> Store.({ see now d with mail_clicks = d.mail_clicks + 1 }))

let from_site nid = 
  let! now = ohmctx (#time) in
  Store.Tbl.update nid 
    (fun d -> Store.({ see now d with site_clicks = d.site_clicks + 1 }))

let from_zap nid = 
  let! now = ohmctx (#time) in
  Store.Tbl.update nid
    (fun d -> Store.({ see now d with zap_clicks = d.zap_clicks + 1 }))

module NotifyStats = CouchDB.ReduceView(struct
  module Key = INotifyStats
  module Value = Fmt.Make(struct
    type json t = < created "c" : int ; sent "st" : int ; seen "sn" : int >
  end)
  module Design = Store.Design
  let name = "stats"
  let map  = "if (doc.r) return;
              if (!doc.s) return;
              emit(doc.s,{ c : 1 , st : (doc.st ? 1 : 0), sn : (doc.sn ? 1 : 0) });"
  let reduce = "var r = { c : 0, st : 0, sn : 0 };
                for (var i = 0; i < values.length; ++i) {
                  r.c += values.c;
                  r.st += values.st;
                  r.sn += values.sn;
                } 
                return r;" 
  let group = false
  let level = None
end)

let zero_stats = object
  method created = 0
  method sent    = 0 
  method seen    = 0
end

let get nsid = 
  let! stats = ohm $ NotifyStats.reduce nsid in 
  return $ BatOption.default zero_stats stats
