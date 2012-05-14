(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open CSend_common
    
let send user url notification p =
  
  let! iid, instance = instance_of notification in
  let! details = ohm (MAvatar.details (p # who)) in
  let  from = name (details # name) in
  
  send_mail_from `item user begin fun uid user send ->
    
    let! context = ohm (CContext.of_user uid iid) in
    let! item = ohm_req_or (return ()) $ MItem.try_get context (p # what) in

    let! text = req_or (return ()) begin match item # payload with 
      | `Message  m -> Some (m # text)
      | `MiniPoll p -> Some (p # text) 
      | `Chat     _ 
      | `Doc      _ 
      | `ChatReq  _ 
      | `Image    _ -> None
    end in

    VMail.Notify.PublishItem.send_from send mail_i18n from
      ~params:[View.str from]
      (object
	method text     = text
	method instance = instance # name
	method from     = from
	method url      = url
       end)
  end
