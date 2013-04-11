(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Act = struct
  open IMail.Action
  let accept  = Some (of_string "accept")
  let decline = Some (of_string "decline")
end

let () = MMembership.Notify.Pending.define begin fun uid u t info -> 

  (* Extract the owner entity for rendering *) 

  let! access = ohm_req_or (return None) (CAccess.of_notification uid (t # iid)) in
  let! owner  = ohm_req_or (return None) begin match t # where with 
    | `Event eid -> let! event = ohm_req_or (return None) (MEvent.view ~actor:(access # actor) eid) in
		    return (Some (`Event event)) 
    | `Group gid -> let! group = ohm_req_or (return None) (MGroup.view ~actor:(access # actor) gid) in
		    return (Some (`Group group))
  end in  

  let kind = match owner with 
    | `Event _ -> `Event
    | `Group _ -> `Group 
  in 

  let  gender = u # gender in 

  (* Make sure that the avatar set can be administrated by this user. *) 

  let  asid = match owner with 
    | `Event event -> MEvent.Get.group event 
    | `Group group -> MGroup.Get.group group 
  in

  let! avset = ohm_req_or (return None) (MAvatarSet.try_get (access # actor) asid) in
  let! avset = ohm_req_or (return None) (MAvatarSet.Can.admin avset) in
  let  asid  = MAvatarSet.Get.id avset in 

  let  key = access # instance # key in

  let  name = begin match owner with 
    | `Event event -> MEvent.Get.fullname event
    | `Group group -> MGroup.Get.fullname group 
  end in 

  return (Some (object

    method act n = let aid = t # from in 
		   let url = match t # where with 
		     | `Event eid -> Action.url UrlClient.Events.join key 
		       [ IEvent.to_string eid ; IAvatar.to_string aid ]
		     | `Group gid -> Action.url UrlClient.Members.join key 
		       [ IGroup.to_string gid ; IAvatar.to_string aid ]
		   in
		   let! () = ohm begin 
		     if n = Act.accept then 
		       let! () = ohm (MMail.solve (info # id)) in
		       MMembership.admin ~from:(access # actor) asid aid [`Accept true]
		     else if n = Act.decline then
		       let! () = ohm (MMail.solve (info # id)) in
		       MMembership.admin ~from:(access # actor) asid aid [`Accept false] 
		     else 
		       return () 
		   end in
		   return url 

    method item = Some begin fun owid ->
      let! name = ohm name in 
      let  time = Date.to_timestamp (info # time) in
      let! now  = ohmctx (#time) in      
      let! author  = ohm (CAvatar.mini_profile (t # from)) in
      let  data = object
	method url  = Action.url UrlMe.Notify.follow owid (info # id,None) 
	method date = (time,now)
	method pic  = author # pico
	method name = Some author # name
	method segs = [ 
	  AdLib.write (`Join_Pending_Notify_Web (`Body (kind, gender))) ; 
	  return Html.(concat [ str "<strong>" ; esc name ; str "</strong>" ]) ;
	]
	method buttons = [
	  (object
	    method green = true
	    method url   = Action.url UrlMe.Notify.follow owid (info # id, Act.accept)
	    method label = AdLib.write (`Join_Pending_Notify_Web `Accept)
	   end) ;
	  (object
	    method green = false
	    method url   = Action.url UrlMe.Notify.follow owid (info # id, Act.decline)
	    method label = AdLib.write (`Join_Pending_Notify_Web `Decline)
	   end) ;
	]
      end in
      match info # solved with 
	| Some (`NotSolved _) -> Asset_Notify_SolvableItem.render data
	| _ -> Asset_Notify_LinkItem.render data
    end

    method mail = let! name = ohm name in 
		  let  title = `Join_Pending_Notify_Mail (`Title name) in
		  
		  let! author  = ohm (CAvatar.mini_profile (t # from)) in

		  let  url act = CMail.link (info # id) act (snd key) in
		  		  
		  let! detail  = ohm begin match owner with 
		    | `Event event -> 
		      let! img     = ohm (CPicture.small_opt (MEvent.Get.picture event)) in
		      let! data    = ohm (MEvent.Get.data event) in
		      VMailBrick.boxProfile ?img ~name
			~detail:(BatOption.default (`Text "")
				   (BatOption.map MEvent.Data.page data))
			(url None)
		    | `Group group -> 
		      VMailBrick.boxProfile ~name ~detail:(`Text "") (url None) 		      
		  end in
		  
		  let  payload = `Action (object
		    method pic    = author # pico
		    method name   = author # name
		    method action = `Join_Pending_Notify_Mail (`Action kind) 
		    method detail = detail
		  end) in 
		  
		  let  body   = [
		    [ `Join_Pending_Notify_Mail `Body ] ;
		  ] in
		  
		  let  buttons = [ 
		    VMailBrick.green (`Join_Pending_Notify_Mail `Accept ) (url Act.accept) ;
		    VMailBrick.grey  (`Join_Pending_Notify_Mail `Decline) (url Act.decline) ; 
		    VMailBrick.grey  (`Join_Pending_Notify_Mail `Detail)  (url None) ;
		  ] in
		  
		  return (title,payload,body,buttons)
		  
  end))

end
