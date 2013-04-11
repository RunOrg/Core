(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Act = struct
  open IMail.Action
  let accept  = Some (of_string "accept")
  let decline = Some (of_string "decline")
end

let () = MMembership.Notify.Invited.define begin fun uid u t info -> 

  let! access = ohm_req_or (return None) (CAccess.of_notification uid (t # iid)) in
  let! event  = ohm_req_or (return None) (MEvent.view ~actor:(access # actor) (t # eid)) in

  let  asid = MEvent.Get.group event in 
  let  key = access # instance # key in
  
  return (Some (object

    method act n = let url = Action.url UrlClient.Events.see key [ IEvent.to_string (t # eid) ] in
		   let! () = ohm begin 
		     if n = Act.accept then 
		       MMembership.user asid (access # actor) true
		     else if n = Act.decline then 
		       MMembership.user asid (access # actor) false
		     else 
		       return () 
		   end in
		   return url 

    method item = Some begin fun owid ->
      let! name = ohm (MEvent.Get.fullname event) in 
      return (Html.esc name) 
    end

    method mail = let! name  = ohm (MEvent.Get.fullname event) in 
		  let  title = `Event_Invite_Notify_Mail (`Title name) in
		  
		  let! author  = ohm (CAvatar.mini_profile (t # from)) in

		  let  url act = CMail.link (info # id) act (snd key) in
		  
		  let! img     = ohm (CPicture.small_opt (MEvent.Get.picture event)) in
		  let! data    = ohm (MEvent.Get.data event) in
		  
		  let! detail  = ohm (VMailBrick.boxProfile ?img ~name
					~detail:(BatOption.default (`Text "")
						   (BatOption.map MEvent.Data.page data))
					(url None)) in
		  
		  let  payload = `Action (object
		    method pic    = author # pico
		    method name   = author # name
		    method action = `Event_Invite_Notify_Mail `Action 
		    method detail = detail
		  end) in 
		  
		  let  body   = [
		    [ `Event_Invite_Notify_Mail (`Body (access # instance # name)) ] ;
		    [ `Event_Invite_Notify_Mail `Body2 ] ;
		  ] in
		  
		  let  buttons = [ 
		    VMailBrick.green (`Event_Invite_Notify_Mail `Accept ) (url Act.accept) ;
		    VMailBrick.grey  (`Event_Invite_Notify_Mail `Decline) (url Act.decline) ; 
		    VMailBrick.grey  (`Event_Invite_Notify_Mail `Detail)  (url None) ;
		  ] in
		  
		  let  footer = CMail.Footer.instance (info # id) uid (access # instance) in 
		  VMailBrick.render title payload body buttons footer
		  
  end))

end
