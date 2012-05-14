(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MNews_common

module DeleteByAvatarView = CouchDB.DocView(struct
  module Key    = IAvatar
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "delete_by_avatar"
  let map  = "if (doc.t == 'news' && doc.a && !doc.b) emit(doc.a,null)"
end)

let _ = 
  let obliterate nid = MyTable.transaction nid MyTable.remove in 
  let on_obliterate_avatar (aid,_) = 
    let! list = ohm $ DeleteByAvatarView.doc aid in 
    let! _ = ohm $ Run.list_map (#id |- INews.of_id |- obliterate) list in
    return ()
  in
  Sig.listen MAvatar.Signals.on_obliterate on_obliterate_avatar
