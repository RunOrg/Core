(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module BecomeMember = CNotifySend_becomeMember
module CommentYourItem = CNotifySend_commentYourItem
module CommentItem = CNotifySend_commentItem

let () = 
  let! uid, payload = Sig.listen MNotify.Send.immediate in 
  let  url = "http://runorg.com/notify" in
  match payload with 
    | `BecomeMember (iid,aid) -> BecomeMember.send url uid iid aid 
    | `NewComment (`ItemAuthor,cid) -> CommentYourItem.send url uid cid
    | `NewComment (`ItemFollower,cid) -> CommentItem.send url uid cid
    | _ -> return ()
