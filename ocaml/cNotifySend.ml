(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module BecomeMember = CNotifySend_becomeMember
module BecomeAdmin = CNotifySend_becomeAdmin
module CommentYourItem = CNotifySend_commentYourItem
module CommentItem = CNotifySend_commentItem
module PublishItem = CNotifySend_publishItem

let () = 
  let! uid, nid, payload = Sig.listen MNotify.Send.immediate in 
  let  token = MNotify.get_token nid in 
  let  url = Action.url UrlMe.Notify.mailed () (nid,token) in
  match payload with 
    | `BecomeMember (iid,aid) -> BecomeMember.send url uid iid aid 
    | `BecomeAdmin (iid,aid) -> BecomeAdmin.send url uid iid aid
    | `NewComment (`ItemAuthor,cid) -> CommentYourItem.send url uid cid
    | `NewComment (`ItemFollower,cid) -> CommentItem.send url uid cid
    | `NewWallItem (_,itid) -> PublishItem.send url uid itid
    | _ -> return ()
