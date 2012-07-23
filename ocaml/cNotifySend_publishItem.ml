(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CNotifySend_common

let send url uid itid = 

  let! iid  = ohm_req_or (return ()) $ MItem.iid itid in     
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in 

  let! _ = ohm $ MMail.other_send_to_self uid begin fun self user send -> 
  
    let! access = ohm_req_or (return ()) $ access iid self in 

    let! item = ohm_req_or (return ()) $ MItem.try_get access itid in

    let! aid = req_or (return ()) $ MItem.author_by_payload (item # payload) in
    
    let! text = req_or (return ()) begin 
      match item # payload with 
	| `Message  m -> Some (m # text)
	| `MiniPoll p -> Some (p # text) 
	| `Image _
	| `Doc _ 
	| `Chat _ 
	| `ChatReq _ -> None
    end in 

    let! author = ohm $ CAvatar.mini_profile aid in 
    let! name = req_or (return ()) (author # nameo) in
    
    let subject = AdLib.get (`Mail_Notify_PublishItem_Title name) in
    
    let body = Asset_Mail_NotifyCommentItem.render (object
      method sender = (name, instance # name)
      method url    = url 
      method asso   = instance # name
      method text   = text
    end) in
    
    let! _, html = ohm $ CMail.Wrap.render ~iid self body in 
    let from = Some name in
    
    send ~from ~subject ~html 
      
  end in
  
  return () 

