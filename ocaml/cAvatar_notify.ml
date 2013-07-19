(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAvatar_common

let empty = `Text "" 

let () = MAvatar.Notify.define begin fun uid u t info -> 

  let  what, iid, from = match t with 
    | `UpgradeToAdmin  (_, iid, from) -> `Admin,  iid, from
    | `UpgradeToMember (_, iid, from) -> `Member, iid, from 
  in

  let  gender  = u # gender in 
		  
  let! instance = ohm_req_or (return None) (MInstance.get iid) in
  let! author   = ohm (mini_profile from) in

  return (Some (object
    method mail = let  title   = `Avatar_Notify_Mail (`Title (instance # name),what,gender) in
		  
		  let  url     = CMail.link (info # id) None (snd (instance # key)) in
		  
		  let! ipic    = ohm (CPicture.small_opt (instance # pic)) in
		  let! iprf    = ohm (MInstance.Profile.get iid) in			
		  let! detail  = ohm (VMailBrick.boxProfile ?img:ipic ~name:(instance # name) 
					~detail:(BatOption.default empty
						   (BatOption.bind iprf (#desc)))
					url) in
		  
		  let  payload = `Action (object
		    method pic    = author # pico
		    method name   = author # name
		    method action = `Avatar_Notify_Mail (`Action,what,gender) 
		    method detail = detail
		  end) in 
		  
		  let  body   = [[ `Avatar_Notify_Mail (`Body (instance # name),what,gender) ]] in
		  
		  let  buttons = [ VMailBrick.green (`Avatar_Notify_Mail (`Button,what,gender)) url ] in
		  
		  return (title,payload,body,buttons)
		    
    method item = Some begin fun owid -> 
      let  time = Date.to_timestamp (info # time) in
      let! now  = ohmctx (#time) in      
      Asset_Notify_LinkItem.render (object
	method url  = Action.url UrlMe.Notify.follow owid (info # id,None) 
	method date = (time,now)
	method pic  = author # pico
	method name = Some author # name
	method segs = [ AdLib.write (`Avatar_Notify_Web (what,gender)) ]
      end)
    end

    method act _ = return (Action.url UrlClient.website (instance # key) ()) 

  end))

end 
