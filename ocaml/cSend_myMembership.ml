(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open CSend_common
    
let become_member user from url instance =
  send_mail `myMembership user
    begin fun uid user send -> 
      VMail.Notify.BecomeMember.send send mail_i18n
	~params:[View.str (instance # name)]		    
	(object
	  method fullname = user # fullname
	  method instance = instance # name
	  method from     = from
	  method url      = url
	 end)
    end
    
let become_admin user from url instance = 
  send_mail `myMembership user
    begin fun uid user send ->
      VMail.Notify.BecomeAdmin.send send mail_i18n
	~params:[View.str (instance # name)]		    
	(object
	  method fullname = user # fullname
	  method instance = instance # name
	  method from     = from
	  method url      = url
	 end)
    end
    
let send uid url notification t =     
  
  let! iid, instance = instance_of notification in
  let! details = ohm $ MAvatar.details (t # who) in
  let from = name (details # name) in	    
  match t # what with 
    | `toMember   -> become_member uid from url instance
    | `toAdmin    -> become_admin  uid from url instance
	
