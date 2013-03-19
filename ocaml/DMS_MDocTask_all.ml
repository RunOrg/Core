(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E = DMS_MDocTask_core

module Default = struct
  module Value = Fmt.Unit
  module Doc = E.Store.Raw
  module Design = struct
    module Database = E.Store.DataDB
    let name = "tasks"
  end
end

module ByDocumentView = CouchDB.DocView(struct
  include Default
  module Key = Fmt.Make(struct type json t = (DMS_IDocument.t * float) end)
  let name = "by_document"
  let map = "emit([doc.c.did,doc.c.state[2]])"
end)

let by_document did = 
  let! now = ohmctx (#time) in
  let  did = DMS_IDocument.decay did in 
  let  startkey = did, now in
  let  endkey = did, 0.0 in
  let! list = ohm $ ByDocumentView.doc_query ~startkey ~endkey ~descending:true ~limit:20 () in
  return (List.map DMS_IDocTask.(#id |- of_id |- Assert.view) list) 

module LastView = CouchDB.DocView(struct
  include Default
  module Key = Fmt.Make(struct type json t = (DMS_IDocument.t * PreConfig_Task.ProcessId.DMS.t * float) end)
  let name = "last"
  let map = "emit([doc.c.did, doc.c.process, doc.c.state[2]])"
end)

let last did prid =
  let! now = ohmctx (#time) in
  let  did = DMS_IDocument.decay did in 
  let  startkey = did, prid, now in
  let  endkey = did, prid, 0.0 in
  let! list = ohm $ LastView.doc_query ~startkey ~endkey ~descending:true ~limit:1 () in
  match list with 
    | x :: _ -> return (Some (DMS_IDocTask.Assert.view (DMS_IDocTask.of_id (x # id))))
    | [] -> return None
