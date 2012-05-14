(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open CSend_common

let send user url notification t =     
  
  let! iid, followed = instance_of notification in

  let! iid' = ohm_req_or (return ()) $ MRelatedInstance.get_follower (t # contact) in 
  let! follower = ohm_req_or (return ()) $ MInstance.get iid' in
  
  send_mail `networkInvite user
    begin fun uid user send ->
      VMail.Notify.NetworkConnect.send send mail_i18n 
	~params:[View.str follower # name]
	(object
	  method follower = follower # name
	  method followed = followed # name
	  method url      = url 
	 end)
    end	
    
