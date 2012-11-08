(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let send url uid iid = 
  
  let! instance = ohm_req_or (return ()) $ MInstance.Profile.get iid in 
  
  let owid = snd (instance # key) in

  if instance # unbound = None then return () else 

    let! _ = ohm $ MMail.other_send_to_self uid begin fun self user send -> 
      
      let subject = AdLib.get (`Mail_Notify_CanInstall_Title (instance # name)) in
      
      (* This is being sent from the instance's owid, because we need
	 to make sure the user is logged in on the appropriate domain.
      *)

      let body = Asset_Mail_CanInstall.render (object
	method url = url owid 
	method asso = instance # name
      end) in
      
      let! _, html = ohm $ CMail.Wrap.render ~iid owid self body in 

      send ~owid ~from:None ~subject ~html 
	
    end in
    
    return () 

