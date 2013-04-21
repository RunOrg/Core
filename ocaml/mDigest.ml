(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Data = struct
  module T = struct
    type json t = {
     ?start : float option ; 
      last  : float ;
     ?sent  : (IInstance.t * float) list = [] ; 
    } 
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "digest-last" end)(IUser)(Data) 

let send_call, send = Sig.make (Run.list_iter identity) 

(* Extracting an item for processing *)

module ByStartView = CouchDB.DocView(struct
  module Key = Fmt.Float
  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design
  let name = "by-start"
  let map = "if (doc.start) emit(doc.start); else emit(doc.last);"
end)

let wait = 3600. *. 24.

let rec process_next action = 
  let! time = ohmctx (#time) in
  let  endkey = time -. wait in 
  let! next = ohm (ByStartView.doc_query ~endkey ~limit:1 ()) in
  match next with [] -> return () | x :: _ -> 
    let  id = IUser.of_id (x # id) and doc = x # doc in 
    let! result = ohm (Tbl.Raw.put id Data.({ doc with start = Some time })) in
    match result with `collision -> process_next action | `ok -> 
      let  sent = List.fold_left (fun m (k,v) -> BatPMap.add k v m) BatPMap.empty doc.Data.sent in
      let! sent = ohm (action id sent) in 
      let! _ = ohm (Tbl.Raw.put id Data.({ start = None ; last = time ; sent })) in
      return () 

(* Registering confirmed users as targets for sending. *)

let start_sending uid = 
  let! _ = ohm (Tbl.ensure uid (lazy Data.({ start = None ; last = 0.0 ; sent = [] }))) in
  return () 

let () = 
  let! uid, _ = Sig.listen MUser.Signals.on_confirm in
  start_sending uid 

(* Backdoor ops *)

module Backdoor = struct

  let migrate_confirmed = Async.Convenience.foreach O.async "digest-migrate-confirmed"
    IUser.fmt (MUser.all_ids ~count:10) 
    (fun uid -> 
      let! confirmed = ohm (MUser.confirmed uid) in
      if not confirmed then return () else start_sending uid)
   
  let migrate_confirmed () = 
    migrate_confirmed () 

end 

