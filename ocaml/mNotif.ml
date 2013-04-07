(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Types = MNotif_types
module All   = MNotif_all 
module Send  = MNotif_send
module Zap   = MNotif_zap 
module Core  = MNotif_core 

include MNotif_plugins

let send f = 
  Send.one f

let zap_unread cuid = 
  Zap.unread (IUser.Deduce.is_anyone cuid) 

let get_token nid = 
  ConfigKey.prove [ "notif" ; INotif.to_string nid ]

let check_token nid token = 
  ConfigKey.is_proof token [ "notif" ; INotif.to_string nid ]

let from_token nid ?current token = 

  let! t = ohm_req_or (return `Missing) (Core.Tbl.get nid) in
  let  extract cuid = 
    O.decay (
      let! full = ohm_req_or (return `Missing) (parse nid t) in
      let! ()   = ohm (Core.seen_from_mail nid) in
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
      if check_token nid token then 
	let cuid = IUser.Assert.is_old t.Core.Data.uid in
	extract cuid 
      else
	return (`Expired t.Core.Data.uid) 
	
let from_user nid cuid = 
  let! t    = ohm_req_or (return None) (Core.Tbl.get nid) in
  if IUser.Deduce.is_anyone cuid = t.Core.Data.uid then 
    O.decay (
      let! full = ohm_req_or (return None) (parse nid t) in
      let! ()   = ohm (Core.seen_from_site nid) in
      return (Some full) 
    )
  else
    return None
