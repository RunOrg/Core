(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open CSend_common
    
let send user url notification r =
  
  let! iid, instance = instance_of notification in
  let! details = ohm (MAvatar.details (r # who)) in
  let  from = name (details # name) in
  
  send_mail_from `item user begin fun uid user send ->
  
    let! entity_name = ohm begin match r # where with 
      | `instance _ -> return None
      | `entity eid -> let! ctx    = ohm (CContext.of_user uid iid) in
		       let! entity = ohm_req_or (return None) (MEntity.try_get ctx eid) in
		       let! entity = ohm_req_or (return None) (MEntity.Can.view entity) in
		       return $ Some (CName.of_entity entity)
    end in 
    
    let where = BatOption.default (`text (instance # name)) entity_name in

    VMail.Notify.ChatRequest.send_from send mail_i18n from
      ~params:[View.str r# topic]
      (object
	method text     = r # topic
	method instance = instance # name
	method where    = where
	method from     = from
	method url      = url
       end)
  end
