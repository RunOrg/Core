(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open CSend_common

let _ = 
  
  let! uid, time, mid, iid = Sig.listen MMessage.Signals.on_send in

  let bmid = IMessage.Assert.bot mid in
  let do_not_send = return () in
  let! details = ohm_req_or (return ()) $ MMessage.bot_get_details bmid in 

  send_mail_from `message uid
    begin fun uid user send ->
      
      let! ()   = true_or do_not_send (user # confirmed) in
      let! ctx  = ohm $ CContext.of_user uid (details # instance) in 
      let! item = ohm_req_or do_not_send $ MItem.try_get ctx iid in  
      
      let! text = req_or do_not_send begin match item # payload with 
	| `Message  m -> Some (m # text)
	| `MiniPoll p -> Some (p # text) 
	| `Doc      _ 
	| `Image    _
	| `ChatReq  _  
	| `Chat     _ -> None
      end in
      
      let! author = req_or do_not_send $ MItem.author (item # payload) in 
      let! last = ohm $ MAvatar.details author in 
      let! inst = ohm_req_or do_not_send $ MInstance.get (details # instance) in
      let  from = name (last # name) in
      let  url  = (UrlCore.message ()) # build (IUser.Deduce.self_can_login uid) mid in
      
      VMail.Message.send_from send mail_i18n from 
	~params:[View.str (details # title)]
	(object
	  method text = text
	  method instance = inst # name
	  method title = details # title
	  method from = from
	  method url = url
	 end)
    end
    
    
