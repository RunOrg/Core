(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

module Unique = MMembership_unique

module Config = struct

  let name = "membership"

  module DataDB    = CouchDB.Convenience.Config(struct let db = O.db "membership"   end)
  module VersionDB = CouchDB.Convenience.Config(struct let db = O.db "membership-v" end) 

  type ctx = O.ctx
  let couchDB ctx = (ctx :> CouchDB.ctx)

  module Id = IMembership
  module Data = MMembership_details
  module Diff = MMembership_diff
  module VersionData = Ohm.Fmt.Unit
  module ReflectedData = MMembership_reflected

  let apply = Diff.apply
  let reflect = ReflectedData.reflect 

end

include OhmCouchVersioned.Make(Config)

module Design = struct
  module Database = DataDB
  let name = "membership"
end

module ByAvatarView = CouchDB.DocView(struct
  module Key    = IAvatar
  module Value  = Fmt.Unit
  module Doc    = Raw
  module Design = Design
  let name = "by_avatar"
  let map  = "emit(doc.c.who,null)"
end)

let by_avatar aid = 
  let! all = ohm $ ByAvatarView.doc (IAvatar.decay aid) in 
  let  list = List.map (fun item -> IMembership.of_id (item # id), item # doc) all in 
  return list

let apply gid aid diffs = 
  let! mid = ohm $ Unique.find gid aid in 
  create ~id:mid ~init:(Config.Data.default gid aid) ~diffs ~info:() ()
