(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Lock = MNews_lock

module Doc = struct
  module T = struct
    type json t = {
      what "w" : [ `Item "i" of IItem.t ] ;
      time "t" : float ;
      uid  "u" : IUser.t ;
      iid  "i" : IInstance.t option ; 
    }
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "news" end)(Id)(Doc)

type t = [ `Item of IItem.t ]

module ByUserView = CouchDB.DocView(struct
  module Key = Fmt.Make(struct type json t = (IUser.t * float) end)
  module Value = Fmt.Unit
  module Doc = Doc
  module Design = Design
  let name = "by_user"
  let map  = "emit([doc.u,doc.t]);"
end)

let raw_user_cache ?start ~count uid =
  let  uid = IUser.decay uid in 
  let! now = ohmctx (#time) in
  let  limit    = count + 1 in
  let  startkey = (uid, BatOption.default now start) in
  let  endkey   = (uid, 0.0) in
  let! list = ohm $ ByUserView.doc_query ~startkey ~endkey ~descending:true ~limit () in
  let  list, next = OhmPaging.slice ~count list in 
  return (
    List.map (fun i -> (i # doc).Doc.what) list,
    BatOption.map (#key |- snd) next 
    )

let cache_item uid item = 
  let uid = IUser.decay uid in 
  let id  = Id.of_string (IUser.to_string uid ^ "-" ^ IItem.to_string (item # id)) in
  let doc = lazy Doc.({
    what = `Item (IItem.decay (item # id)) ;
    time = item # time ;
    uid  ;
    iid  = Some (item # iid)
  }) in
  let! _ = ohm $ Tbl.ensure id doc in
  return () 

module CacheTaskArgs = Fmt.Make(struct type json t = (IUser.t * float) end)

let cache_task = O.async # define "news-cache" CacheTaskArgs.fmt begin fun (uid,since) ->

  let! now = ohmctx (#time) in
  
  (* Acting as self to preview items. A view check is performed upon rendering
     anyway, as the module does not let readable items escape. *)
  let uid = IUser.Assert.is_self uid in 
  let! avatars = ohm $ MAvatar.user_avatars uid in

  let! items = ohm (Run.list_collect begin fun (self, isin) ->

    let access = object 
      method self = self 
      method isin = isin 
    end in 
  
    let readable fid = 
      let! feed = ohm_req_or (return None) (MFeed.try_get access fid) in
      let! feed = ohm_req_or (return None) (MFeed.Can.read feed) in
      return (Some (MFeed.Get.id feed))
    in

    MItem.news ~self ~since readable (IIsIn.instance isin) 

  end avatars) in

  let! () = ohm (Run.list_iter (cache_item uid) items) in

  Lock.release (IUser.decay uid)
								 
end
  
let prepare uid = 
  let  uid = IUser.decay uid in 
  let! lock = ohm $ Lock.grab uid in 
  if not lock # locked then
    cache_task (uid, lock # last)
  else
    return () 

let head ~count uid = 
  let uid = IUser.decay uid in 
  let! lock = ohm $ Lock.grab uid in 
  let! () = ohm (if not lock # locked then cache_task (uid, lock # last) else return ()) in
  let! list, next = ohm (raw_user_cache ~count uid) in
  return (lock # recent, list, next)

let rest ~count uid start = 
  raw_user_cache ~count ~start uid
