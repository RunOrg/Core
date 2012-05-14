(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Arr  = MChat_arr
module Line = MChat_line
module Feed = MChat_feed

module Float = Fmt.Float

module Data = struct
  module T = struct
    type json t = {
      instance "iid" : IInstance.t ;
      wall     "fid" : IFeed.t ;
      key            : string ;
      active         : bool ;
      created  "t"   : Float.t
    }
  end
  include T
  include Fmt.Extend(T)
end

module MyDB = MModel.Register(struct let db = "chat-room" end)
module MyTable = CouchDB.Table(MyDB)(IChat.Room)(Data)

module Design = struct
  module Database = MyDB
  let name = "room"
end

module Signals = struct
  let on_appear_call, on_appear = Sig.make (Run.list_iter identity)
  let on_create_call, on_create = Sig.make (Run.list_iter identity)
end

let check_activity_task = Task.declare "chat-room-check-deactivate" IChat.Room.fmt

let check_activity delay crid =
    let! _ = ohm $ MModel.Task.delay delay check_activity_task (IChat.Room.decay crid) in
    return () 

let () = 
  Task.define check_activity_task
    begin fun crid _ -> 
      
      let! latest, _ = ohm $ Feed.list ~count:1 crid in
      
      let  last_message_time = 
	match latest with [] -> 0.0 | h :: _ -> 
	  match h # payload with 
	    | `text t -> t.Line.text_time
      in

      let activity_delay = 60. *. 10. in (* 10 minutes *)

      let! () = ohm $ begin
	if Unix.gettimeofday () -. activity_delay > last_message_time then
	  let deactivate room = Data.({ room with active = false }) in
	  let! _ = ohm $ MyTable.transaction crid (MyTable.update deactivate) in
	  return ()
	else
	  check_activity 60. crid
      end in 

      return $ Task.Finished crid
 
    end

let check_appear_task = Task.declare "chat-room-check-appear" IChat.Room.fmt	
let check_appear crid = 
  let! _ = ohm $ MModel.Task.delay 30. check_appear_task (IChat.Room.decay crid) in
  return ()

let () = 
  Task.define check_appear_task begin fun crid _ -> 

    let! data = ohm_req_or (return $ Task.Finished crid) $ MyTable.get crid in 
    let! ()   = true_or (return $ Task.Finished crid) data.Data.active in 

    let! _, next = ohm $ Feed.list ~count:0 crid in
    
    if next <> None then 
      let! () = ohm $ Signals.on_appear_call crid in
      return $ Task.Finished crid
    else
      let! () = ohm $ check_appear crid in 
      return $ Task.Finished crid
      
  end 
  
let create feed = 

  let! time = ohmctx (#time) in

  let data = Data.({ 
    instance = MFeed.Get.instance feed ;
    wall     = IFeed.decay $ MFeed.Get.id feed ;
    active   = true ;
    created  = time ;
    key      = Digest.to_hex (Digest.string (Util.uniq () ^ string_of_int (Random.int 65535)))
  }) in

  let crid = IChat.Room.gen () in
  
  let! _  = ohm $ MyTable.transaction crid (MyTable.insert data) in
  let  () = Arr.create (IChat.Room.to_id crid) data.Data.key in
  let! () = ohm $ check_activity 600. crid in
  let! () = ohm $ check_appear   crid in
  let! () = ohm $ Signals.on_create_call (IChat.Room.Assert.created crid, feed) in

  return (IChat.Room.Assert.post crid)

module ActiveView = CouchDB.MapView(struct
  module Key    = IInstance
  module Value  = IFeed
  module Design = Design
  let name = "active"
  let map  = "if (doc.active) emit(doc.iid,doc.fid)"
end)

let all_active iid = 
  let! list = ohm $ ActiveView.by_key (IInstance.decay iid) in
  return $ List.map (#value) list

module RecentView = CouchDB.DocView(struct
  module Key    = Fmt.Make(struct type json t = IFeed.t * Float.t end)
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "recent"
  let map  = "emit([doc.fid,doc.t])"
end)

let recent feed = 
  let  fid  = IFeed.decay (MFeed.Get.id feed) in
  let! time = ohmctx (#time) in
  let! last = ohm $ RecentView.doc_query 
    ~startkey:(fid,time+.3600.) ~endkey:(fid,0.0) ~descending:true ~limit:2 () in
  
  let first, second = match last with 
    | []  -> None, None
    | [a] -> if (a # doc).Data.active then Some a, None else None, Some a 
    | a :: b :: _ -> if (a # doc).Data.active then Some a, Some b else None, Some a
  in

  let! first = ohm begin match first with 
    | Some a -> return (IChat.Room.Assert.post $ IChat.Room.of_id a # id) (* Is active *)
    | None   -> create feed 
  end in

  let second = BatOption.map 
    (fun item -> IChat.Room.Assert.view $ IChat.Room.of_id (item # id)) second in 

  return (first,second)

let ensure crid = 
  let  crid = IChat.Room.decay crid in 
  let! room = ohm_req_or (return ()) $ MyTable.get crid in 
  let () = Arr.create (IChat.Room.to_id crid) room.Data.key in
  return ()

let close crid = 
  
  let crid = IChat.Room.decay crid in 

  let update data = Data.({ data with active = false }) in
  let! _ = ohm $ MyTable.transaction crid (MyTable.update update) in
  
  let () = Arr.delete (IChat.Room.to_id crid) in
  return ()

let url crid aid = 
  
  let  crid = IChat.Room.decay crid in 
  let! room = ohm_req_or (return None) $ MyTable.get crid in 

  if room.Data.active then 
    return $ Some (Arr.user_url 
		     (IChat.Room.to_id crid)
		     (IAvatar.to_id aid) 
		     (room.Data.key))

  else
    return None

let send crid line = 
  let json = Line.to_json line in 
  Arr.post (IChat.Room.to_id crid) json ;
  return () 

let active crid = 
  let  crid   = IChat.Room.decay crid in 
  let! room   = ohm_req_or (return None) $ MyTable.get crid in 
  if room.Data.active then
    return $ Some (IChat.Room.Assert.post crid) 
  else
    return None

let readable crid fid = 
  let  crid   = IChat.Room.decay crid in 
  let! room = ohm_req_or (return None) $ MyTable.get crid in 
  if room.Data.wall = IFeed.decay fid then
    return $ Some (IChat.Room.Assert.view crid) 
  else
    return None
  
