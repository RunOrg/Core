(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open MAvatar_common

module PictureView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct
    type json t = IInstance.t * Id.t
  end)

  module Value  = Fmt.Unit
  module Doc    = MAvatar_common.Data
  module Design = Design
  let name = "with_picture" 
  let map  = "if (doc.t == 'avtr' && (doc.sta == 'mbr' || doc.sta == 'own') && doc.picture) 
    emit([doc.ins,doc.picture],null)" 
end)

let with_pictures  ~count instance = 

  let instance = IInstance.decay instance in 

  let startkey = instance, Id.largest in
  let endkey   = instance, Id.smallest in 
  let limit    = count in

  let! members = ohm $ PictureView.doc_query 
    ~startkey
    ~endkey
    ~limit
    ~descending:true
    ~endinclusive:true
    ()
  in

  return (List.map (#id |- IAvatar.of_id) members) 

module MemberView = CouchDB.DocView(struct
  module Key    = IInstance
  module Value  = Fmt.Unit
  module Doc    = MAvatar_common.Data
  module Design = Design
  let name = "all-members" 
  let map  = "if (doc.t == 'avtr' && (doc.sta == 'mbr' || doc.sta == 'own')) emit(doc.ins)" 
end)

let all_members iid =

  let iid = IInstance.decay iid in 

  let! members = ohm $ MemberView.doc iid in

  return (List.map (#id |- IAvatar.of_id) members) 

