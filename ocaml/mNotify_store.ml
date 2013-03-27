(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Payload = MNotify_payload

type t = <
  id      : INotify.t ; 
  payload : Payload.t ;
  time    : float ;
  seen    : bool 
>

(* Define data types ------------------------------------------------------------------------ *)

module Data = struct
  module T = struct
    type json t = {
      payload     "p"  : Payload.t ;
      created     "t"  : float ;
      uid         "u"  : IUser.t ;
      seen        "sn" : float option ;
      sent        "st" : float option ;
      mail_clicks "mc" : int ;
      site_clicks "sc" : int ;
     ?zap_clicks  "zc" : int = 0 ;
      rotten      "r"  : bool ;
      delayed     "d"  : bool ;
      stats       "s"  : INotifyStats.t option 
    }
  end
  include T
  include Fmt.Extend(T)
end

type data = Data.t = {
  payload     : Payload.t ;
  created     : float ;
  uid         : IUser.t ;
  seen        : float option ;
  sent        : float option ;
  mail_clicks : int ;
  site_clicks : int ;
  zap_clicks  : int ; 
  rotten      : bool ;
  delayed     : bool ;
  stats       : INotifyStats.t option 
}

include CouchDB.Convenience.Table(struct let db = O.db "notify" end)(INotify)(Data)

(* Implement functions ---------------------------------------------------------------------- *)

let create ?stats payload user = 

  let! time  = ohmctx (#time) in

  let data = Data.({
    payload ;
    created = time ;
    uid     = user ;
    seen    = None ;
    sent    = None ;
    mail_clicks = 0 ;
    site_clicks = 0 ;
    zap_clicks  = 0 ;
    rotten  = false ;
    delayed = false ;
    stats   ;
  }) in
 

  Run.map ignore (Tbl.create data) 

let extract nid notify = 
  (object
    method id      = nid
    method payload = notify.payload
    method time    = notify.created
    method seen    = notify.seen <> None
   end)

let rotten nid = 
  Tbl.Raw.transaction nid begin fun nid -> 
    let! notify = ohm_req_or (return ((),`keep)) $ Tbl.get nid in 
    if notify.Data.rotten then return ((),`keep) else
      return ((),`put Data.({ notify with rotten = true }))
  end

let get_mine cuid nid = 
  let! notify = ohm_req_or (return None) $ Tbl.get nid in 
  if notify.Data.uid = IUser.Deduce.is_anyone cuid then 
    return $ Some (extract nid notify)
  else
    return None

(* Display notifications from an user ------------------------------------------------------- *)

module ByUser = CouchDB.DocView(struct
  module Key    = Fmt.Make(struct
    type json t = (IUser.t * float)
  end)
  module Value  = Fmt.Unit
  module Doc    = Data
  module Design = Design
  let name = "by_user"
  let map = "if (!doc.r) emit([doc.u,doc.t]);"
end)

let all_mine ~count ?start cuid = 

  let  uid  = IUser.Deduce.is_anyone cuid in 
  let! time = ohmctx (#time) in

  let startkey = uid, BatOption.default time start in
  let endkey   = uid, 0.0 in
  let limit    = count + 1 in

  let! list = ohm $ ByUser.doc_query ~startkey ~endkey ~limit ~descending:true () in
  let  list, next = OhmPaging.slice ~count list in 
  
  let extract item = object
    method id      = INotify.of_id item # id
    method payload = (item # doc).Data.payload
    method time    = (item # doc).Data.created
    method seen    = (item # doc).Data.seen <> None
  end in

  return (List.map extract list, BatOption.map (#key |- snd) next) 

(* Display unread notifications for an user ------------------------------------------------- *)

module UnseenByUser = CouchDB.DocView(struct
  module Key    = IUser
  module Value  = Fmt.Int
  module Doc    = Data
  module Design = Design
  (* Same as CountByUser view below *)
  let name = "count_by_user"
  let map = "if (!doc.r && !doc.sn) emit(doc.u,1);"
end)

let get_unread ~count cuid = 
  let  uid  = IUser.Deduce.is_anyone cuid in 
  let! list = ohm $ UnseenByUser.doc_query ~startkey:uid ~endkey:uid ~limit:count () in 
  return (List.map (#id |- INotify.of_id) list) 

(* Count unseen notifications for an user --------------------------------------------------- *)

module CountByUser = CouchDB.ReduceView(struct
  module Key    = IUser
  module Value  = Fmt.Int
  module Design = Design
  let name = "count_by_user"
  let map = "if (!doc.r && !doc.sn) emit(doc.u,1);"
  let reduce = "return sum(values);"
  let group = true
  let level = None
end)

let count_mine cuid = 
  let  uid = IUser.Deduce.is_anyone cuid in 
  let! count = ohm $ CountByUser.reduce uid in 
  return $ BatOption.default 0 count 

