(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Info  = MProfileForm_info
module Store = MProfileForm_store

(* ============================================================================= *)

module ByAvatar = CouchDB.DocView(struct
  module Key    = Fmt.Make(struct type json t = (IAvatar.t * float) end)
  module Value  = Fmt.Unit
  module Doc    = Store.Raw
  module Design = Store.Design
  let name = "by_avatar"
  let map = "emit([doc.c.aid,doc.c.c[0]])"
end)

let by_avatar aid _ = 
  let! now = ohmctx (#time) in
  let  startkey = IAvatar.decay aid, now +. 3600. in
  let  endkey   = IAvatar.decay aid, 0.0 in
  let! list = ohm $ ByAvatar.doc_query ~startkey ~endkey ~limit:100 ~descending:true () in 
  return $ List.map begin fun item -> 
    (* An administrator is accessing this *)
    let pfid = IProfileForm.Assert.edit (IProfileForm.of_id item # id) in
    let info = item # doc # current in 
    pfid, info 
 end list

(* ============================================================================= *)

module Mine = CouchDB.DocView(struct
  module Key    = Fmt.Make(struct type json t = (IAvatar.t * float) end)
  module Value  = Fmt.Unit
  module Doc    = Store.Raw
  module Design = Store.Design
  let name = "mine"
  let map = "if (!doc.c.h) emit([doc.c.aid,doc.c.c[0]])"
end)

let mine actor = 
  let  aid = MActor.avatar actor in
  let! now = ohmctx (#time) in
  let  startkey = IAvatar.decay aid, now +. 3600. in
  let  endkey   = IAvatar.decay aid, 0.0 in
  let! list = ohm $ Mine.doc_query ~startkey ~endkey ~limit:100 ~descending:true () in 
  return $ List.map begin fun item -> 
    (* The profile owner is accessing this *)
    let pfid = IProfileForm.Assert.view (IProfileForm.of_id item # id) in
    let info = item # doc # current in 
    pfid, info 
 end list

let as_parent aid actor = 
  let! now = ohmctx (#time) in
  let! pid = ohm $ MAvatar.profile aid in 
  let! is_parent = ohm $ MProfile.is_parent (MActor.avatar actor) pid in
  if is_parent then 
    let  startkey = IAvatar.decay aid, now +. 3600. in
    let  endkey   = IAvatar.decay aid, 0.0 in
    let! list = ohm $ Mine.doc_query ~startkey ~endkey ~limit:100 ~descending:true () in 
    return $ List.map begin fun item -> 
      (* A parent is accessing this *)
      let pfid = IProfileForm.Assert.view (IProfileForm.of_id item # id) in
      let info = item # doc # current in 
      pfid, info 
    end list
  else
    return []

