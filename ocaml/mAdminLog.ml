(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Data type definitions ----------------------------------------------------------------------------------- *)

module Payload = struct
  module T = struct
    type json t = 
	MembershipInvite        "mi"  of IEntity.t * IAvatar.t * int
      | MembershipAdd           "ma"  of IEntity.t * IAvatar.t * int
      | MembershipInviteAccept  "mia" of IEntity.t * IAvatar.t 
      | MembershipInviteDecline "mid" of IEntity.t * IAvatar.t 
      | MembershipRequest       "mr"  of IEntity.t * IAvatar.t
      | MembershipLeave         "ml"  of IEntity.t * IAvatar.t 
      | MembershipValidate      "mv"  of IEntity.t * IAvatar.t
      | InstanceCreate          "ic"
      | LoginManual             "lm"
      | LoginSignup             "ls"
      | LoginWithNotify         "ln"  of MNotifyChannel.t
      | LoginWithReset          "lr"
      | NotifyClickMail         "ncm" of MNotifyChannel.t 
      | NotifyClickSite         "ncs" of MNotifyChannel.t
      | UserConfirm             "uc"
      | ItemCreate              "itc" of IItem.t
      | CommentCreate           "cc"  of IComment.t 
      | EntityCreateGroup       "ecg" of IEntity.t 
      | EntityCreateEvent       "ece" of IEntity.t 
      | EntityCreateForum       "ecf" of IEntity.t 
      | BroadcastPublish        "bp"  of IBroadcast.t
  end
  include T
  include Fmt.Extend(T)
end

module Data = Fmt.Make(struct
  type json t = <
    uid  : IUser.t ;
    iid  : IInstance.t option ;
    what : Payload.t ;
    time : float
  >
end)

type t = Data.t 

(* Database definition ------------------------------------------------------------------------------------- *)

include CouchDB.Convenience.Table(struct let db = O.db "alog" end)(Id)(Data)

let log ?id ~uid ?iid ?time payload = 

  let! now  = ohmctx (#time) in
  let  time = BatOption.default now time in 
  let  data = object
    method uid  = uid
    method iid  = iid
    method time = time
    method what = payload
  end in 

  match id with 
    | None -> let id = Id.gen () in
	      let! _ = ohm $ MyTable.put id data in
	      return () 

    | Some id -> let! _ = ohm $ MyTable.put id data in
		 return () 

