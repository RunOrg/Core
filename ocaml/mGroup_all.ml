(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E   = MGroup_core
module Can = MGroup_can
module Get = MGroup_get

module AllView = CouchDB.DocView(struct
  module Key    = IInstance
  module Value  = Fmt.Unit
  module Doc    = E.Raw
  module Design = E.Design
  let name = "all"
  let map  = "if (!doc.c.del) emit(doc.c.iid)"
end) 

let viewable ?actor item = 
  let eid  = IGroup.of_id (item # id) in
  let data = item # doc in 
  match Can.make eid ?actor data with
    | None   -> return None
    | Some t -> Can.view t 

let visible ?actor iid =
  let iid = IInstance.decay iid in 
  O.decay begin 
    let! list = ohm $ AllView.doc_query ~startkey:iid ~endkey:iid ~limit:50 () in
    Run.list_filter (viewable ?actor) list 
  end

