(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E   = DMS_MDocument_core
module Can = DMS_MDocument_can
module Get = DMS_MDocument_get

module IRepository = DMS_IRepository

type entry = < 
  doc     : [`Unknown] Can.t ; 
  name    : string ; 
  version : int ; 
  update  : float * IAvatar.t ;
>

module TimeByRepoView = CouchDB.DocView(struct
  module Key    = Fmt.Make(struct type json t = (IRepository.t * float) end)
  module Value  = Fmt.Unit
  module Doc    = E.Raw
  module Design = E.Design
  let name = "time_by_repo"
  let map  = "for (var k = 0; k < doc.c.repos.length; ++k) 
                emit([doc.c.repos[k],doc.c.last[0]])"
end) 

let entry ?actor item = 
  let did  = DMS_IDocument.of_id (item # id) in
  let data = item # doc in
  match Can.make did ?actor data with 
    | None   -> return None
    | Some t -> return (Some (object
      method doc     = t
      method name    = Get.name t
      method version = Get.version t
      method update  = Get.last_update t
    end)) 

let in_repository ?actor ?start ~count rid =
  let rid = IRepository.decay rid in
  let start = BatOption.default max_float start in
  let startkey = (rid, start) and endkey = (rid, 0.0) in
  O.decay begin 
    let! list = ohm $ TimeByRepoView.doc_query ~startkey ~endkey ~descending:true ~limit:(count+1) () in
    let  list, next = OhmPaging.slice ~count list in     
    let! list = ohm $ Run.list_filter (entry ?actor) list in
    let  next = BatOption.map (#key |- snd) next in
    return (list, next)
  end

