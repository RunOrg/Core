(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Data type definitions ----------------------------------------------------------------------------------- *)

module Payload = struct
  module T = struct
    type json t = 
        MembershipMass          "mm"  of [ `Invite "i" | `Add "a" | `Remove "r" | `Validate "v" | `Create "c"
					 ] * IEntity.t * int
      | MembershipAdmin         "ma"  of [ `Invite "i" | `Add "a" | `Remove "r" | `Validate "v" 
					 ] * IEntity.t * IAvatar.t
      | MembershipUser          "mu"  of bool * IEntity.t 
      | InstanceCreate          "ic"
      | LoginManual             "lm"
      | LoginSignup             "ls"
      | LoginWithNotify         "ln"  of MNotifyChannel.t
      | LoginWithReset          "lr"
      | UserConfirm             "uc"
      | ItemCreate              "it"  of IItem.t
      | CommentCreate           "cc"  of IComment.t 
      | EntityCreate            "ec"  of [ `Event "e" | `Forum "f" | `Group "g" ] * IEntity.t 
      | BroadcastPublish        "bp"  of [ `Post "p" | `Forward "f" ] * IBroadcast.t
      | SendMail                "m"   
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

(* Database definition --------------------------------------------------------------------- *)

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
    | None -> Run.map ignore (Tbl.create data)
    | Some id -> Tbl.set id data 

