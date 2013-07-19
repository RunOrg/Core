(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module E   = MEvent_core
module Can = MEvent_can
module Get = MEvent_get

module DatedView = CouchDB.DocView(struct
  module Key    = Fmt.Make(struct type json t = (IInstance.t * Date.t) end)
  module Value  = Fmt.Unit
  module Doc    = E.Raw
  module Design = E.Design
  let name = "dated"
  let map  = "if (!doc.c.del && doc.c.date) emit([doc.c.iid,doc.c.date])"
end) 

module UndatedView = CouchDB.DocView(struct
  module Key    = IInstance
  module Value  = Fmt.Unit
  module Doc    = E.Raw 
  module Design = E.Design
  let name = "undated"
  let map  = "if (!doc.c.del && !doc.c.date) emit(doc.c.iid)"
end)

let viewable ?actor item = 
  let eid  = IEvent.of_id (item # id) in
  let data = item # doc in 
  match Can.make eid ?actor data with
    | None   -> return None
    | Some t -> Can.view t 

let future ?actor iid =
  let iid = IInstance.decay iid in 
  O.decay begin 
    let! now = ohmctx (#date) in
    let  startkey = (iid,Date.day_only now) in
    let  endkey   = (iid,Date.max) in
    let! list = ohm $ DatedView.doc_query ~startkey ~endkey ~limit:25 () in
    Run.list_filter (viewable ?actor) list 
  end

let undated ~actor iid =
  let iid = IInstance.decay iid in 
  O.decay begin 
    let! list = ohm $ UndatedView.doc_query ~startkey:iid ~endkey:iid ~limit:25 () in
    Run.list_filter (viewable ~actor) list 
  end

let rec past ?actor ?start ~count iid =
  let iid = IInstance.decay iid in 
  O.decay begin 

    let  limit = count + 1 in

    let! now      = ohmctx (#date %> Date.day_only) in
    let  startkey, startid = match start with 
      | Some (date,eid) -> (iid,date), Some (IEvent.to_id eid)
      | None            -> (iid,now),  None
    in

    let  endkey   = (iid,Date.min) in
    let! list = ohm $ DatedView.doc_query ~descending:true ~startkey ?startid ~endkey ~limit () in    

    let  list, next = OhmPaging.slice ~count list in 

    let  next = BatOption.map (fun next -> (snd next # key), IEvent.of_id (next # id)) next in 
    let! list = ohm $ Run.list_filter (viewable ?actor) list in

    (* If it happens to day, don't show as past yet. *)    
    let  list = List.filter (fun t -> match Get.date t with 
      | None -> false
      | Some date -> Date.day_only date <> now) list
    in

    return (list, next) 

  end 
