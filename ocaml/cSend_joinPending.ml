(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open CSend_common

let send uid url notification t =     
  
  let! iid, instance = instance_of notification in     
  let! details = ohm (MAvatar.details (t # who)) in     
  let from = name (details # name) in
  
  send_mail `pending uid begin fun uid user send ->
        
    let! ctx    = ohm (CContext.of_user uid iid) in
    let! entity = ohm_req_or (return ()) (MEntity.try_get ctx (t # what)) in
    let! entity = ohm_req_or (return ()) (MEntity.Can.view entity) in
    
    let entity = CName.of_entity entity in 
    
    VMail.Notify.JoinPending.send send mail_i18n 
      ~params:[View.str from]
      (object
	method fullname  = user # fullname
	method instance  = instance # name
	method entity    = entity
	method from      = from
	method url       = url
       end)
  end
