(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open CSend_common

let send user url notification t =     
  
  let! iid, instance = instance_of notification in
  let! details = ohm $ MAvatar.details (t # who) in
  let from = name (details # name) in	    
  send_mail_from `networkInvite user
    begin fun uid user send ->
      VMail.Notify.NetworkInvite.send_from send mail_i18n from 
	~params:[View.str t # contacted]
	(object
	  method text     = t # text
	  method instance = instance # name
	  method url      = url 
	 end)	  
    end	
    
