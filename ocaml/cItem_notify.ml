(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = MItem.Notify.define begin fun uid u t info -> 

  let! access = ohm_req_or (return None) (CAccess.of_notification uid (t # iid)) in
  let! item   = ohm_req_or (return None) (MItem.try_get (access # actor) (t # itid)) in
  let! mail   = req_or (return None) (match item # payload with 
    | `Mail mail -> Some mail
    | `MiniPoll _ 
    | `Image _ 
    | `Doc _ 
    | `Message _ -> None) in
					    
  return (Some (object

    method mail = let title = `Item_Notify_Title (mail # subject) in
		  let url   = CMail.link (info # id) None (snd (access # instance # key)) in

		  let! author = ohm (CAvatar.mini_profile (mail # author)) in

		  let payload = `Social (object
		    method pic  = author # pico
		    method name = author # name
		    method context = access # instance # name
		    method body = `Text (mail # body) 
		  end) in

		  let body = [[ `Item_Notify_Body ]] in
		  let button = [ VMailBrick.green `Item_Notify_Button url ] in
		  
		  let footer = CMail.Footer.instance (info # id) uid (access # instance) in
		  VMailBrick.render title payload body button footer
		  

    method act _ = return ("")

    method item = None


  end))

end 
