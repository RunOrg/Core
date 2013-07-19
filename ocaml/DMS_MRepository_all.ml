(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E   = DMS_MRepository_core
module Can = DMS_MRepository_can
module Get = DMS_MRepository_get

module AllView = CouchDB.DocView(struct
  module Key    = IInstance
  module Value  = Fmt.Unit
  module Doc    = E.Raw
  module Design = E.Design
  let name = "all"
  let map  = "if (!doc.c.del) emit(doc.c.iid)"
end) 

let viewable ?actor item = 
  let rid  = DMS_IRepository.of_id (item # id) in
  let data = item # doc in 
  match Can.make rid ?actor data with
    | None   -> return None
    | Some t -> Can.view t 

let visible ?actor ?start ~count iid =
  let iid = IInstance.decay iid in
  let startid = BatOption.map DMS_IRepository.to_id start in
  O.decay begin 
    let! list = ohm $ AllView.doc_query ~startkey:iid ?startid ~endkey:iid ~limit:(count+1) () in
    let  list, next = OhmPaging.slice ~count list in     
    let! list = ohm $ Run.list_filter (viewable ?actor) list in
    let  next = BatOption.map (#id %> DMS_IRepository.of_id) next in
    return (list, next)
  end

