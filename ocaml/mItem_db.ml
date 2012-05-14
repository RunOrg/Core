(* © 2012 RunOrg *)

open Ohm

module MyDB = MModel.Register(struct let db = "item" end)

module Design = struct
  module Database = MyDB
  let name = "item"
end

module MyTable = CouchDB.Table(MyDB)(IItem)(MItem_data)

module ByAvatarView = CouchDB.DocView(struct
  module Key    = IAvatar
  module Value  = Fmt.Unit
  module Doc    = MItem_data
  module Design = Design
  let name = "by_avatar"
  let map  = "if (doc.p[1].a) emit(doc.p[1].a);" 
end)

module ByChatRoom = CouchDB.DocView(struct
  module Key    = IChat.Room
  module Value  = Fmt.Unit
  module Doc    = MItem_data
  module Design = Design
  let name = "by_avatar"
  let map  = "if (doc.p[0] == 'c') emit(doc.p[1].r);" 
end)
