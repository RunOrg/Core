(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CNotifySend_common

let send url uid cid = 

  let! itid = ohm_req_or (return ()) $ MComment.item cid in 
  let! iid  = ohm_req_or (return ()) $ MItem.iid itid in     
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in 

  let! _ = ohm $ MMail.Send.other_send_to_self uid begin fun self user send -> 
  
    let! actor = ohm_req_or (return ()) $ actor iid self in 

    let! item = ohm_req_or (return ()) $ MItem.try_get actor itid in
    let! _, comm = ohm_req_or (return ()) $ MComment.try_get (item # id) cid in 

    let! author = ohm $ CAvatar.mini_profile (comm # who) in 
    let! name = req_or (return ()) (author # nameo) in
    
    let subject = AdLib.get (`Mail_Notify_CommentYourItem_Title name) in
    
    let owid = snd (instance # key) in

    let body = Asset_Mail_NotifyCommentYourItem.render (object
      method sender = (name, instance # name)
      method url    = url owid
      method asso   = instance # name
      method text   = comm # what
    end) in
    
    let! _, html = ohm $ CMail.Wrap.render ~iid (user # white) self body in 
    let from = Some name in
    
    send ~owid ~from ~subject ~html 
      
  end in
  
  return () 

