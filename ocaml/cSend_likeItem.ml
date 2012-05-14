(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open CSend_common

let send user url notification i = 
  
  let! iid, instance = instance_of notification in
  let! details = ohm $ MAvatar.details (i # who) in
  let from = name (details # name) in
  
  send_mail `likeItem user begin fun uid user send ->
    
    let! ctx = ohm (CContext.of_user uid iid) in
    let  aid = BatOption.map IAvatar.decay (ctx # self_if_exists)  in
    let! item = ohm_req_or (return()) $ MItem.try_get ctx (i # on) in
    let! author = req_or (return ()) $ MItem.author (item # payload) in
    
    if Some author = aid then		    
      VMail.Notify.LikeYourItem.send send mail_i18n 
	~params:[View.str from]
	(object
	  method fullname = user # fullname
	  method instance = instance # name
	  method from     = from
	  method url      = url 
	 end)
    else if i # who = author then 
      VMail.Notify.LikeTheirItem.send send mail_i18n 
	~params:[View.str from]
	(object
	  method fullname = user # fullname
	  method instance = instance # name
	  method from     = from
	  method url      = url 
	 end)
    else
      let! author = ohm $ MAvatar.details author in
      VMail.Notify.LikeItem.send send mail_i18n 
	~params:[View.str from]
	(object
	  method author   = name (author # name) 
	  method fullname = user # fullname
	  method instance = instance # name
	  method from     = from
	  method url      = url 
	 end)
  end
