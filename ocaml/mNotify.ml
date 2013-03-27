(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Payload = MNotify_payload
module Store   = MNotify_store
module Stats   = MNotify_stats
module Create  = MNotify_create
module ToUser  = MNotify_toUser
module Send    = MNotify_send

let zap_unread_task, def_zap_unread_task = O.async # declare "notify-zap-unread" ICurrentUser.fmt 
let zap_unread uid =
  let! list = ohm $ Store.get_unread ~count:10 uid in
  let! () = ohm $ Run.list_iter Stats.from_zap list in 
  if list <> [] then zap_unread_task uid else return () 

let () = def_zap_unread_task zap_unread

let zap_unread cuid = zap_unread (ICurrentUser.decay cuid) 

let get_token nid = 
  ConfigKey.prove [ "notify" ; INotify.to_string nid ] 

let from_token nid token current = 
  let! notify = ohm_req_or (return `Missing) $ Store.Tbl.get nid in
  let  uid    = notify.Store.uid in 
  let!   ()   = true_or (return $ `Expired uid) 
    (ConfigKey.is_proof token [ "notify" ; INotify.to_string nid ]) in
  let  notify = Store.extract nid notify in 
  match current with 
    | Some cuid when IUser.Deduce.is_anyone cuid = uid -> return (`Valid (notify,cuid)) 
    | _ -> 

      (* We can confirm the user, because this token was sent as an e-mail. *)
      let  uid = IUser.Assert.confirm uid in 
      let! confirmed = ohm $ MUser.confirm uid in 
      if confirmed then  
	(* User is confirmed, log in *)
	return $ `Valid (notify,IUser.Assert.is_old uid)
      else
	(* Not confirmed : this means the user is missing. *)
	return $ `Missing
