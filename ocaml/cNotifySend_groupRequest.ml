(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CNotifySend_common

let send url uid eid aid = 

  let! iid  = ohm_req_or (return ()) $ MEntity.instance eid in 
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in 

  let! _ = ohm $ MMail.other_send_to_self uid begin fun self user send -> 
  
    let! access = ohm_req_or (return ()) $ access iid self in 
    let! entity = ohm_req_or (return ()) $ MEntity.try_get access eid in 
    let! entity = ohm_req_or (return ()) $ MEntity.Can.view entity in 
    let! entity = ohm $ CEntityUtil.name entity in 

    let! author = ohm $ CAvatar.mini_profile aid in 
    let! name = req_or (return ()) (author # nameo) in
    
    let subject = AdLib.get (`Mail_Notify_GroupRequest_Title (name,entity)) in
    
    let owid = snd (instance # key) in

    let body = Asset_Mail_NotifyGroupRequest.render (object
      method name      = user # fullname
      method requester = (name, entity, instance # name)
      method url       = url owid
      method asso      = instance # name
    end) in
    
    let! _, html = ohm $ CMail.Wrap.render ~iid (user # white) self body in 
    let from = Some name in
    
    send ~owid ~from ~subject ~html 
      
  end in
  
  return () 

