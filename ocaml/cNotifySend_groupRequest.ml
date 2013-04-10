(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CNotifySend_common

let send url uid gid aid = 

  let! iid  = ohm_req_or (return ()) $ MGroup.instance gid in 
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in 

  let! _ = ohm $ MMail.Send.other_send_to_self uid begin fun self user send -> 
  
    let! actor = ohm_req_or (return ()) $ actor iid self in 
    let! group = ohm_req_or (return ()) $ MGroup.view ~actor gid in 
    let! group = ohm $ MGroup.Get.fullname group in 

    let! author = ohm $ CAvatar.mini_profile aid in 
    let! name = req_or (return ()) (author # nameo) in
    
    let subject = AdLib.get (`Mail_Notify_GroupRequest_Title (name,group)) in
    
    let owid = snd (instance # key) in

    let body = Asset_Mail_NotifyGroupRequest.render (object
      method name      = user # fullname
      method requester = (name, group, instance # name)
      method url       = url owid
      method asso      = instance # name
    end) in
    
    let! _, html = ohm $ CMail.Wrap.render ~iid (user # white) self body in 
    let from = Some name in
    
    send ~owid ~from ~subject ~html 
      
  end in
  
  return () 

