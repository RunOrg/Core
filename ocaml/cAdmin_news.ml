(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let color = function
  | `item -> "GreenYellow"
  | `join `requested   -> "LightCyan"
  | `join (`added _)   -> "LightSteelBlue"
  | `join (`removed _) -> "PaleTurquoise"
  | `join (`invited _) -> "PowderBlue"
  | `join `denied      -> "AliceBlue"
  | `createInstance -> "plum"
  | `networkConnect -> "PeachPuff"
  | `login -> "Tomato"

let message = function
  | `item -> "Nouveau message"
  | `join `requested      -> "Liste: Demande Validation"
  | `join (`added None)   -> "Liste: Auto-Inscription"
  | `join (`added _)      -> "Liste: Inscription Tiers"
  | `join (`removed None) -> "Liste: Auto-Retrait"
  | `join (`removed _)    -> "Liste: Retrait Tiers"
  | `join (`invited _)    -> "Liste: Invitation tiers" 
  | `join `denied         -> "Liste: Refus Invitation"
  | `createInstance -> "Création association"
  | `networkConnect -> "Suivi association"
  | `login          -> "Connexion"

let string_of_time t = 
  let tm = Unix.localtime t in 
  Printf.sprintf "%02d:%02d %02d/%02d/%04d"
    (tm.Unix.tm_hour)
    (tm.Unix.tm_min)
    (tm.Unix.tm_mday)
    (tm.Unix.tm_mon + 1)
    (tm.Unix.tm_year + 1900)

let string_of_channel = function
  | `myMembership  -> "Inscription Membre ou Admin"
  | `message       -> "Message Privé"
  | `likeItem      -> "Favoris"
  | `commentItem   -> "Commentaire"
  | `welcome       -> "Bienvenue"
  | `subscription  -> "Invitation Adhésion"
  | `event         -> "Invitation Event"
  | `forum         -> "Invitation Forum"
  | `album         -> "Invitation Album"
  | `group         -> "Invitation Groupe"
  | `poll          -> "Invitation Sondage"
  | `course        -> "Invitation Cours"
  | `pending       -> "Demande Validation"
  | `item          -> "Message Public"
  | `networkInvite -> "Invitation Réseau"
  | `digest        -> "Digest"
  | `chatReq       -> "Invitation Chat Room"

let render_core time pic name mail what where more = 
  View.str "<tr><td><img style=\"width:30px\" src=\""
  |- View.esc pic
  |- View.str "\"/></td><td><div style=\"font-weight:bold;line-height:10px\">"
  |- View.esc name
  |- View.str "</div><div style=\"font-size:10px;color:#666\"/>"
  |- View.esc mail 
  |- View.str "</div></td><td><div style=\"border:1px solid black;padding:2px;font-size:10px;text-align:center;background-color:"
  |- View.esc (color what) 
  |- View.str "\">"
  |- View.esc (message what) 
  |- View.str "</div></td><td><div style=\"font-size:10px;color:#666\">"
  |- View.esc (string_of_time time)
  |- View.str "</div></td><td>"
  |- View.str where
  |- View.str "</td><td>"
  |- (match more with 
      | `None -> identity 
      | `Text _ -> identity 
      | `Notif channel -> View.esc channel
      | `Follow (name,key) -> 
	View.str "&rArr; "
        |- View.esc name 
        |- View.str " - <b>"
        |- View.esc key
	|- View.str "</b>.runorg.com")
  |- View.str "</td></tr>"
  |- (match more with 
      | `None -> identity
      | `Text text -> 
	View.str "<tr><td colspan='6'><div style='font-size:9px;color:#888;margin:0px'>"
        |- View.str (VText.format text)
	|- View.str "</div></td></tr>"
      | `Follow (name,key) -> identity
      | `Notif  (channel)  -> identity)

let instance_name i = 
  match i with None -> return "" | Some i -> 
    let! instance = ohm (MInstance.get i) in
    match instance with 
      | None -> return ""
      | Some instance -> return ("<b>"^instance # key^"</b>.runorg.com")

let avatar_email admin uid_opt = 
  let fail = return "(no email)" in
  let! uid  = req_or fail uid_opt in
  let! user = ohm_req_or fail (MUser.admin_get admin uid) in
  return (user # email) 

let read_avatar admin i18n a = 
  let! details = ohm (MAvatar.details a) in  
  let! pic     = ohm (CPicture.small (details # picture)) in
  let! where   = ohm (instance_name (details # ins)) in
  let! email   = ohm (avatar_email admin (details # who)) in
  let name = CName.get i18n details in
  return (pic, name, where, email)
	
let render_item admin time i18n = function
  | `item i -> 

    let! item = ohm_req_or (return None) (MItem.Backdoor.get i) in
    let!  who = req_or (return None) (MItem.author (item # payload)) in
    let! (pic,name,where,email) = ohm (read_avatar admin i18n who) in
    let!    t = req_or (return None) begin match item # payload with 
      | `Message  m -> Some (m # text)
      | `MiniPoll p -> Some (p # text)
      | `Doc      d -> Some (d # title)
      | `ChatReq  r -> Some (r # topic)
      | `Chat     _ 
      | `Image    _ -> None
    end in 
    return (Some (render_core (item#time) pic name email `item where (`Text t)))

  | `join j -> 

    let actor = match j#s with 
      | `invited a -> a
      | `denied    -> j#a
      | `added   o -> BatOption.default (j#a) o
      | `removed o -> BatOption.default (j#a) o
      | `requested -> j#a
    in

    let! (pic,name,where,email) = ohm (read_avatar admin i18n actor) in
    return (Some (render_core (j#t) pic name email (`join (j#s)) where `None))

  | `createInstance i ->

    let! instance = ohm_req_or (return None) (MInstance.get i) in
    let! isin     = ohm (MAvatar.identify_user i (IUser.Assert.is_self instance # usr)) in
    let! avatar   = ohm (MAvatar.get isin) in
    
    let! (pic,name,where,email) = ohm (read_avatar admin i18n avatar) in
    return (Some (render_core time pic name email `createInstance where `None))

  | `login (`Login uid) -> 

    let! user  = ohm_req_or (return None) (MUser.admin_get admin uid) in
    let! pic   = ohm $ CPicture.small (user # picture) in
    let  name  = user # fullname in
    let  email = user # email in

    return (Some (render_core time pic name email `login "" `None)) 

  | `login (`Notification (iid,channel,uid)) -> 

    let! user  = ohm_req_or (return None) (MUser.admin_get admin uid) in
    let! pic   = ohm $ CPicture.small (user # picture) in
    let  name  = user # fullname in
    let  email = user # email in

    let! where   = ohm $ instance_name (Some iid) in

    let  channel = string_of_channel channel in 

    return (Some (render_core time pic name email `login where (`Notif channel))) 

  | `networkConnect rid ->

    (* We are superadmins... *)
    let  rid = IRelatedInstance.Assert.admin rid in 
    let! rel = ohm_req_or (return None) $ MRelatedInstance.get_data rid in

    let! instance = ohm_req_or (return None) 
      (MInstance.get rel.MRelatedInstance.Data.related_to) in
    let  avatar   = rel.MRelatedInstance.Data.created_by in 

    let iid' = match rel.MRelatedInstance.Data.bind with 
      | `Bound iid -> Some iid 
      | _          -> rel.MRelatedInstance.Data.profile 
    in

    let! iid' = req_or (return None) iid' in
    let! profile = ohm_req_or (return None) $ MInstance.Profile.get iid' in
    let name' = profile # name and key' = profile # key in

    let! (pic,name,where,email) = ohm (read_avatar admin i18n avatar) in
    return (Some (render_core time pic name email `networkConnect where 
		    (`Follow (name',key'))))


let render admin i18n list = 
  let! views = ohm (Run.list_filter (fun (time,item) -> render_item admin time i18n item) list) in
  return (View.concat views)
  
let () = CAdmin_common.register UrlAdmin.news begin fun i18n user request response ->
  
  let! latest = ohm (MNews.Backdoor.since 0.0) in

  let! render = ohm (render user i18n latest) in
  
  let title = return (View.esc "Live Feed") in
  
  let body = 
    return begin 
      View.str "<table style=\"margin:auto\">"
      |- render 
      |- View.str "</table>"
    end
  in

  CCore.render ~title ~body response  

end

