(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module ByOwner = MInboxLine_byOwner

let count o n = object
  method old_count = o
  method new_count = n
  method read      = if n > 0 then Some o else None 
  method unread    = if n > o then Some (n-o) else None
end

module Count = Fmt.Make(struct

  type t = <
    old_count : int ;
    new_count : int ;
    unread    : int option ; 
    read      : int option ; 
  >

  let t_of_json = function
    | Json.Array [ Json.Int o ; Json.Int n] -> count o n
    | _ -> raise (Json.Error "MInboxLine.View.Count")

  let json_of_t t = 
    Json.Array [ Json.Int (t # old_count) ;
		 Json.Int (t # new_count) ]

end)

let viewed c = 
  count (c # new_count) (c # new_count) 
      
module Data = struct
  module T = struct
    type json t = {
      aid    : IAvatar.t ;
      ilid   : IInboxLine.t ; 
      album  : Count.t ;
      folder : Count.t ;
      wall   : Count.t ; 
      seen   : float ; 
      last   : float ; 
    }
  end
  include T
  include Fmt.Extend(T)
end

let default ilid aid = Data.({
  ilid   = IInboxLine.decay ilid ;
  aid    = IAvatar.decay aid ;
  album  = count 0 0 ;
  folder = count 0 0 ;
  wall   = count 0 0 ;
  seen   = 0.0 ;
  last   = 0.0 ;
})

let markviewed now view =
  Data.({ view with
    album  = viewed view.album ;
    wall   = viewed view.wall ;
    folder = viewed view.folder ;
    seen   = max view.last now
  }) 

include CouchDB.Convenience.Table(struct let db = O.db "inbox-line-view" end)(IInboxLine.View)(Data)

let update ilid aid line = 
  Tbl.replace (IInboxLine.View.make ilid aid) begin fun view_opt ->
    let view = BatOption.default (default ilid aid) view_opt in 
    let count old f x = count (old # old_count) (BatOption.default 0 (BatOption.map f x)) in
    match line.Line.last with None -> view | Some (time,author) ->
      let view = Data.({ view with 
	album  = count view.album  (fun a -> a.Info.Album.n)  line.Line.album ;
	folder = count view.folder (fun f -> f.Info.Folder.n) line.Line.folder ;
	wall   = count view.wall   (fun w -> w.Info.Wall.n)   line.Line.wall ;
	last   = time ; 
      }) in
      if author = IAvatar.decay aid then markviewed time view else view
  end

let mark actor iloid = 
  let  aid = MActor.avatar actor in
  let! ilid = ohm_req_or (return ()) $ ByOwner.get iloid in
  let! now = ohmctx (#time) in
  Tbl.update (IInboxLine.View.make ilid aid) (markviewed now)

type t = <
  owner  : IInboxLineOwner.t ;
  wall   : Count.t ;
  folder : Count.t ;
  album  : Count.t ; 
  time   : float ;
  seen   : bool ;
  aid    : IAvatar.t ;
>

module ByInboxView = CouchDB.DocView(struct
  module Key    = Fmt.Make(struct type json t = (IAvatar.t * float) end)
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "by-inbox"
  let map = "emit([doc.aid,doc.last])"			   
end)

let list ?start ~count actor f = 
  let  aid = IAvatar.decay (MActor.avatar actor) in
  let! now = ohmctx (#time) in
  let  startkey = match start with None -> (aid,now) | Some time -> (aid,time) in
  let  endkey   = (aid,0.0) in
  let  limit    = count + 1 in
  let! list = ohm $ ByInboxView.doc_query ~startkey ~endkey ~limit ~descending:true () in
  
  let delete ilvid = 
    let! () = ohm $ Tbl.delete ilvid in 
    return None
  in 

  let extract item = 
    let  ilvid = IInboxLine.View.of_id (item # id) in
    let  view  = item # doc in 
    let  ilid  = view.Data.ilid in
    let! line  = ohm_req_or (delete ilvid) $ MInboxLine_common.Tbl.get ilid in
    let! _, aid = req_or (delete ilvid) line.Line.last in
    if not line.Line.show then delete ilvid else
      let data : t = object
	method owner = line.Line.owner
	method wall  = view.Data.wall
	method folder = view.Data.folder
	method album = view.Data.album
	method time = view.Data.last
	method seen = view.Data.seen >= view.Data.last
	method aid  = aid 
      end in
      let! result = ohm_req_or (delete ilvid) $ f data in
      return (Some result) 
  in

  let  list, next = OhmPaging.slice ~count list in 
  let! list = ohm $ Run.list_filter extract list in 
  let  next = BatOption.map (#key |- snd) next in

  return (list, next) 
