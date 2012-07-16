(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Payload = MNotify_payload
module Store   = MNotify_store

let to_admins payload = 
  Run.list_iter (Store.create payload) (MAdmin.list ())

(* Create a notification when a new instance is created ----------------------------------------------------- *)

let () = 
  let! iid = Ohm.Sig.listen MInstance.Signals.on_create in 
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in
  let! aid = ohm $ MAvatar.become_contact iid (instance # usr) in
  to_admins (`NewInstance (IInstance.decay iid, aid))

(* Create a notification when a new user is confirmed ------------------------------------------------------- *)

let () = 
  let! uid, _ = Ohm.Sig.listen MUser.Signals.on_confirm in
  to_admins (`NewUser (IUser.decay uid)) 

(* Create a notification when an user joins an instance ----------------------------------------------------- *)

let () = 
  () (* Not implemented yet *)
