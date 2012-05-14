(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

open CSend_common

let invite (kind,renderer) eid user from url iid instance = 
  send_mail kind user
    begin fun uid user send ->
      
      let! ctx    = ohm (CContext.of_user uid iid) in
      let! entity = ohm_req_or (return ()) (MEntity.try_get ctx eid) in
      let! entity = ohm_req_or (return ()) (MEntity.Can.view entity) in
      
      let entity_name = CName.of_entity entity in 
      
      renderer send mail_i18n  
	?params:(Some [View.str (instance # name)])
	(object
	  method fullname = user # fullname
	  method instance = instance # name
	  method entity   = entity_name
	  method from     = from
	  method url      = url
	 end)
    end
    
let invite_by_kind kind =
  invite (match kind with 
    | `Subscription -> `subscription, VMail.Notify.InviteSubscription.send 
    | `Event        -> `event,        VMail.Notify.InviteEvent.send
    | `Group        -> `group,        VMail.Notify.InviteGroup.send
    | `Forum        -> `forum,        VMail.Notify.InviteForum.send
    | `Album        -> `album,        VMail.Notify.InviteAlbum.send
    | `Poll         -> `poll,         VMail.Notify.InvitePoll.send
    | `Course       -> `course,       VMail.Notify.InviteCourse.send)
    
let send uid url notification t =     
  let! iid, instance = instance_of notification in 
  let! details = ohm (MAvatar.details (t # who)) in
  let from = name (details # name) in
  match t # how with 
    | `invite -> invite_by_kind (t # kind) (t # what) uid from url iid instance    
      
