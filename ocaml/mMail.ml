(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Send     = MMail_send
module Types    = MMail_types
module All      = MMail_all 
module Compose  = MMail_compose
module Zap      = MMail_zap 
module Core     = MMail_core 
module Backdoor = MMail_backdoor

include MMail_plugins

let track mid = 
  Core.opened mid 

let zap_unread cuid = 
  Zap.unread (IUser.Deduce.is_anyone cuid) 

let get_token mid = 
  ConfigKey.prove [ "mail" ; IMail.to_string mid ]

let check_token mid token = 
  ConfigKey.is_proof token [ "mail" ; IMail.to_string mid ]

let from_token mid ?current token = 

  let! t = ohm_req_or (return `Missing) (Core.Tbl.get mid) in
  let  extract cuid = 
    O.decay (
      let! full = ohm_req_or (return `Missing) (parse_mail mid t) in
      let! ()   = ohm (Core.clicked mid) in
      return (`Valid (full, cuid))
    )
  in

  match current with 
    (* If the notification is owned by the current user, don't bother
       checking the authentication token. *) 
    | Some cuid when IUser.Deduce.is_anyone cuid = t.Core.Data.uid -> 
      extract cuid 

    (* The notification owner is not logged in. Attempt authentication. *)
    | _ -> 
      if check_token mid token then 
	let cuid = IUser.Assert.is_old t.Core.Data.uid in
	extract cuid 
      else
	return (`Expired t.Core.Data.uid) 
	
let from_user mid cuid = 
  let! t    = ohm_req_or (return None) (Core.Tbl.get mid) in
  if IUser.Deduce.is_anyone cuid = t.Core.Data.uid then 
    O.decay (
      let! full = ohm_req_or (return None) (parse_item mid t) in
      let! ()   = ohm (Core.zap mid) in
      return (Some full) 
    )
  else
    return None
