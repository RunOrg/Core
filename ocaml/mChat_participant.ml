(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Float = Fmt.Float

module Data = struct
  module T = struct
    open IChat
    type json t = {
      room    "r" : Room.t ;
      avatar  "a" : IAvatar.t ;
      time    "t" : Float.t
    }
  end
  include T
  include Fmt.Extend(T)
end

let make_id crid self = 
  Id.of_string (IChat.Room.to_string crid ^ "-" ^ IAvatar.to_string self) 

module MyDB = MModel.Register(struct let db = "chat-participant" end)
module MyTable = CouchDB.Table(MyDB)(Id)(Data)
module Design = struct
  module Database = MyDB
  let name = "participant"
end

let participate aid crid = 
  let id     = make_id crid aid in 
  let update id = 
    let! data_opt = ohm $ MyTable.get id in 
    let  data = BatOption.default Data.({ room = crid ; avatar = aid ; time = 0. }) data_opt in
    return ((), `put Data.({ data with time = Unix.gettimeofday () }))
  in
  MyTable.transaction id update

module CountView = CouchDB.ReduceView(struct
  module Key    = IChat.Room
  module Value  = Fmt.Int
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

module ListView = CouchDB.MapView(struct
  module Key    = Fmt.Make(struct
    open IChat
    type json t = Room.t * IAvatar.t 
  end)
  module Value  = Fmt.Unit
  module Design = Design
  let name   = "list"
  let map    = "emit([doc.r,doc.a])"
end)

let list ?start ~count crid = 

  let crid = IChat.Room.decay crid in 

  let startkey   = match start with 
    | None     -> crid, IAvatar.of_id Id.largest
    | Some aid -> crid, aid
  and endkey     = crid, IAvatar.of_id Id.smallest
  and descending = true
  and limit      = count + 1 in

  let! list = ohm $ ListView.query ~startkey ~endkey ~descending ~limit () in
  
  let list, next = OhmPaging.slice ~count list in 
  
  return begin 
    List.map      (#key |- snd) list,
    BatOption.map (#key |- snd) next
  end

