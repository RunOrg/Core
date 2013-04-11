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

  let  gender = u # gender in 

  let  asid = MEvent.Get.group event in 
  let  key = access # instance # key in
  
  return (Some (object

    method act n = let url = Action.url UrlClient.Events.see key [ IEvent.to_string (t # eid) ] in
		   let! () = ohm begin 
		     if n = Act.accept then 
		       let! () = ohm (MMail.solve (info # id)) in
		       MMembership.user asid (access # actor) true
		     else if n = Act.decline then
		       let! () = ohm (MMail.solve (info # id)) in 
		       MMembership.user asid (access # actor) false
		     else 
		       return () 
		   end in
		   return url 

    method item = Some begin fun owid ->
      let! name = ohm (MEvent.Get.fullname event) in 
      let  time = Date.to_timestamp (info # time) in
      let! now  = ohmctx (#time) in      
      let! author  = ohm (CAvatar.mini_profile (t # from)) in
      let  data = object
	method url  = Action.url UrlMe.Notify.follow owid (info # id,None) 
	method date = (time,now)
	method pic  = author # pico
	method name = Some author # name
	method segs = [ 
	  AdLib.write (`Event_Invite_Notify_Web (`Body gender)) ; 
	  return Html.(concat [ str "<strong>" ; esc name ; str "</strong>" ]) ;
	]
	method buttons = [
	  (object
	    method green = true
	    method url   = Action.url UrlMe.Notify.follow owid (info # id, Act.accept)
	    method label = AdLib.write (`Event_Invite_Notify_Web `Accept)
	   end) ;
	  (object
	    method green = false
	    method url   = Action.url UrlMe.Notify.follow owid (info # id, Act.decline)
	    method label = AdLib.write (`Event_Invite_Notify_Web `Decline)
	   end) ;
	]
      end in
      match info # solved with 
	| Some (`NotSolved _) -> Asset_Notify_SolvableItem.render data
	| _ -> Asset_Notify_LinkItem.render data
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
		  
		  return (title,payload,body,buttons)
		  
  end))

end
