(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let send url uid iid aid = 
  
  let! author = ohm $ CAvatar.mini_profile aid in 
  let! name = req_or (return ()) (author # nameo) in
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in 
  
  let! _ = ohm $ MMail.other_send_to_self uid begin fun self user send -> 
    
    let subject = AdLib.get (`Mail_Notify_BecomeMember_Title (instance # name)) in
    
    let body = Asset_Mail_NotifyBecomeMember.render (object
      method name = user # fullname
      method invite = (name, instance # name) 
      method url = url (snd (instance # key))
      method asso = instance # name
    end) in
    
    let! _, html = ohm $ CMail.Wrap.render ~iid (user # white) self body in 
    let from = Some name in
    
    send ~from ~subject ~html 
      
  end in
  
  return () 

