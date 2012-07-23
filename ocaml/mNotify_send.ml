(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Store   = MNotify_store
module Payload = MNotify_payload
module ToUser  = MNotify_toUser

let immediate_call, immediate = Sig.make (Run.list_iter identity)

module Unsent = CouchDB.DocView(struct
  module Key    = Fmt.Float
  module Value  = Fmt.Unit
  module Doc    = Store.Data
  module Design = Store.Design
  let name = "unsent"
  let map = "if (doc.r === false && !doc.sn && !doc.st && !doc.d) emit(doc.t);"
end)

let send = 
  let! next = ohm $ Unsent.doc_query ~limit:1 () in

  (* Wait 10 seconds if no item needs sending. *)
  let! nid, next = req_or (return $ Some 10.0) begin 
    match next with 
      | [] -> None
      | h :: _ -> Some (INotify.of_id h # id, h # doc) 
  end in

  let uid, payload = Store.( next.uid , next.payload ) in

  let! freq = ohm $ ToUser.send uid payload in 

  if freq = `Immediate then 

    (* Immediate sending : run the signal, mark as sent *)
    let! now = ohmctx (#time) in
    let sent d = Store.({ d with sent = Some now }) in

    let!  ( ) = ohm $ immediate_call (uid,nid,payload) in
    let!   _  = ohm $ Store.MyTable.transaction nid (Store.MyTable.update sent) in
    return None

  else
    
    (* Delayed sending : mark as delayed. *)
    let delay d = Store.({ d with delayed = true }) in
    let! _ = ohm $ Store.MyTable.transaction nid (Store.MyTable.update delay) in
    return None

let () = 
  O.async # periodic 5 send
