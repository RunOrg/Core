(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAvatar_common

let () = MAvatar.Notify.define begin fun t info -> 

  let  what, uid, iid, from = match t with 
    | `UpgradeToAdmin  (uid, iid, from) -> `Admin,  uid, iid, from
    | `UpgradeToMember (uid, iid, from) -> `Member, uid, iid, from 
  in
 
  let! instance = ohm_req_or (return None) (MInstance.get iid) in
  let! author   = ohm (mini_profile from) in

  return (Some (object
    method mail uid u = let  title   = `Avatar_Notify_Mail (`Title (instance # name),what) in
			let  payload = `Action (object
			  method pic    = author # pico
			  method name   = author # name
			  method action = `Avatar_Notify_Mail (`Action,what) 
			  method html   = Html.str ""
			  method text   = ""					   
			end) in 
			let  body   = [[ `Avatar_Notify_Mail (`Body (instance # name),what) ]] in
			let  button = object
			  method color = `Green
			  method url   = CMail.link (info # id) None (snd (instance # key))
			  method label = `Avatar_Notify_Mail (`Button,what) 
			end in 
			let footer = CMail.Footer.instance (info # id) uid instance in 
			VMailBrick.render title payload body button footer
    method item   = None
    method act _ _ _ = return (Action.url UrlClient.website (instance # key) ()) 
  end))

end 
