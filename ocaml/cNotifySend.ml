(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module CommentYourItem = CNotifySend_commentYourItem
module CommentItem = CNotifySend_commentItem
module PublishItem = CNotifySend_publishItem
module EventInvite = CNotifySend_eventInvite
module EventRequest = CNotifySend_eventRequest
module GroupRequest = CNotifySend_groupRequest
module CanInstall = CNotifySend_canInstall

let () = 
  let! uid, nid, payload = Sig.listen MNotify.Send.immediate in 
  let  token = MNotify.get_token nid in 
  let  url owid = Action.url UrlMe.Notify.mailed owid (nid,token) in
  match payload with 
    | `NewComment (`ItemAuthor,cid) -> CommentYourItem.send url uid cid
    | `NewComment (`ItemFollower,cid) -> CommentItem.send url uid cid
    | `NewWallItem (_,itid) -> PublishItem.send url uid itid
    | `EventInvite (eid,aid) -> EventInvite.send url uid eid aid 
    | `EventRequest (eid,aid) -> EventRequest.send url uid eid aid 
    | `GroupRequest (eid,aid) -> GroupRequest.send url uid eid aid 
    | `CanInstall iid -> CanInstall.send url uid iid 
    | `BecomeMember _ 
    | `BecomeAdmin _
    | `NewUser _ 
    | `NewFavorite _ 
    | `NewInstance _
    | `NewJoin _ -> return () 
