(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Line = MChat_line

module Data = struct
  open Line
  open IChat
  module T = struct
    type json t = {
      payload "p" : Payload.t ;
      room    "r" : Room.t
    }
  end
  include T
  include Fmt.Extend(T)
end

module MyDB = MModel.Register(struct let db = "chat-line" end)
module MyTable = CouchDB.Table(MyDB)(IChat.Line)(Data)
module Design = struct
  module Database = MyDB
  let name = "line"
end

let post payload room = 
  let room = IChat.Room.decay room in
  let line = Data.({ payload ; room }) in
  let clid = IChat.Line.gen () in
  let! _ = ohm $ MyTable.transaction clid (MyTable.insert line) in
  return $ Line.make (IChat.Line.to_id clid) payload 

module CountView = CouchDB.ReduceView(struct
  module Key = IChat.Room
  module Value = Fmt.Int
  module Design = Design
  let name   = "count"
  let map    = "emit(doc.r,1)"
  let reduce = "return sum(values);"
  let group  = true
  let level  = None
end)

let count crid = 
  let  crid  = IChat.Room.decay crid in 
  let! count = ohm_req_or (return 0) $ CountView.reduce crid in
  return count

module ListView = CouchDB.DocView(struct
  module Key   = Fmt.Make(struct
    open IChat
    type json t = Room.t * Line.t 
  end)
  module Value = Fmt.Unit
  module Doc   = Data
  module Design = Design
  let name   = "list"
  let map    = "emit([doc.r,doc._id])"
end)

let list ?start ?(reverse=false) ~count crid = 

  let crid = IChat.Room.decay crid in 

  let startkey = match start with 
    | None      -> crid, IChat.Line.of_id (if reverse then Id.smallest else Id.largest)
    | Some clid -> crid, clid
  and endkey = crid, IChat.Line.of_id (if reverse then Id.largest else Id.smallest)
  and descending = not reverse
  and limit = count + 1 in

  let! list = ohm $ ListView.doc_query ~startkey ~endkey ~descending ~limit () in
  
  let list, next = OhmPaging.slice ~count list in 
  
  return begin 
    List.map (fun i -> Line.make (i # id) (i # doc).Data.payload) list,
    BatOption.map (#id |- IChat.Line.of_id) next
  end

