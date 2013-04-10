(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CNotifySend_common

let send url uid itid = 

  let! iid  = ohm_req_or (return ()) $ MItem.iid itid in     
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in 

  let! _ = ohm $ MMail.Send.other_send_to_self uid begin fun self user send -> 
  
    let! actor = ohm_req_or (return ()) $ actor iid self in 

    let! item = ohm_req_or (return ()) $ MItem.try_get actor itid in

    let! aid = req_or (return ()) $ MItem.author_by_payload (item # payload) in
    
    let! body, title = req_or (return ()) begin 
      match item # payload with 
	| `Mail     m -> Some (m # body, m # subject)
	| `Message  _
	| `MiniPoll _
	| `Image _
	| `Doc _  -> None
    end in 

    let! author = ohm $ CAvatar.mini_profile aid in 
    let! name = req_or (return ()) (author # nameo) in
    
    let subject = return title in 
    
    let owid = snd (instance # key) in

    let body = Asset_Mail_NotifyPublishItem.render (object
      method sender = (name, instance # name)
      method url    = url owid
      method asso   = instance # name
      method text   = body
    end) in
    
    let! _, html = ohm $ CMail.Wrap.render ~iid (user # white) self body in 
    let from = Some name in
    
    send ~owid ~from ~subject ~html 
      
  end in
  
  return () 

