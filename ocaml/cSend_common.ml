(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

let mail_i18n = MModel.I18n.load (Id.of_string "i18n-common-fr") `Fr

let name = function 
  | Some name -> name 
  | None      -> I18n.translate mail_i18n (`label "anonymous")

let can_send user (kind : MUser.Notification.t) = 
  if kind = `welcome then not (user # confirmed) else
    not (List.mem kind (user # blocktype))

let instance_of notification callback = 
  let! iid = req_or (return ()) (notification # inst) in
  let! instance = ohm_req_or (return ()) $ MInstance.get iid in
  callback (iid,instance)

let send_mail kind user contents = 
  MMail.send_to_self user 
    (fun uid user send -> 
      if not (can_send user kind) then 
	return () 
      else 
	contents uid user send)
  |> Run.map ignore

let send_mail_from kind user contents =
  MMail.other_send_to_self user
    (fun uid user send -> 
      if not (can_send user kind) then 
	return () 
      else 
	contents uid user send)
  |> Run.map ignore
