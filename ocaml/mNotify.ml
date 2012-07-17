(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Payload = MNotify_payload
module Store   = MNotify_store
module Stats   = MNotify_stats
module Create  = MNotify_create
module ToUser  = MNotify_toUser

let get_token nid = 
  ConfigKey.prove [ "notify" ; INotify.to_string nid ] 

let from_token nid token current = 
  let! () = true_or (return `Expired) (ConfigKey.is_proof token [ "notify" ; INotify.to_string nid ]) in
  let! notify = ohm_req_or (return `Missing) $ Store.MyTable.get nid in
  let  uid  = notify.Store.Data.uid in 
  match current with 
    | Some cuid when IUser.Deduce.is_anyone cuid = uid -> return (`Valid cuid) 
    | _ -> 

      (* We can confirm the user, because this token was sent as an e-mail. *)
      let  uid = IUser.Assert.confirm uid in 
      let! confirmed = ohm $ MUser.confirm uid in 
      if confirmed then  
	(* User is confirmed, log in *)
	return $ `Valid (IUser.Assert.is_old uid)
      else
	(* Not confirmed : return a new-user to allow setting password. *)
	return $ `New (IUser.Assert.is_new uid) 
