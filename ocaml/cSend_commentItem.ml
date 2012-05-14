(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal
  
open CSend_common

let send user url notification c =
  
  let! iid, instance = instance_of notification in
  let! details = ohm $ MAvatar.details (c # who) in
  let from = name (details # name) in
  
  send_mail `commentItem user begin fun uid user send ->     
    let! ctx     = ohm (CContext.of_user uid iid) in
    let  avatar  = BatOption.map IAvatar.decay (ctx # self_if_exists) in 
    let! item    = ohm_req_or (return ()) (MItem.try_get ctx (c # on)) in
    let! _, comm = ohm_req_or (return ()) (MComment.try_get (item # id) (c # what)) in
    let! author  = req_or (return ()) $ MItem.author (item # payload) in 
    
    if Some author = avatar then 
      VMail.Notify.CommentYourItem.send send mail_i18n
	~params:[View.str from]
	(object
	  method fullname = user # fullname
	  method instance = instance # name
	  method from     = from
	  method text     = comm # what
	  method url      = url
	 end)
    else if author = c # who then 
      VMail.Notify.CommentTheirItem.send send mail_i18n
	~params:[View.str from]
	(object
	  method fullname = user # fullname
	  method instance = instance # name
	  method from     = from
	  method text     = comm # what
	  method url      = url
	 end)
    else
      let! author = ohm $ MAvatar.details author in
      VMail.Notify.CommentItem.send send mail_i18n
	~params:[View.str from]
	(object
	  method author   = name (author # name) 
	  method fullname = user # fullname
	  method instance = instance # name
	  method from     = from
	  method text     = comm # what
	  method url      = url
	 end)
	
  end
    
