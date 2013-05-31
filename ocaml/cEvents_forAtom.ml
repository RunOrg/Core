(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render actor atom = 

  let! now  = ohmctx (#time) in   
  let  default = return (Html.esc (atom # label)) in 

  let  eid = IEvent.of_id (IAtom.to_id (atom # id)) in
  let! event = ohm_req_or default (MEvent.view ~actor eid) in
  let! pico = ohm (CPicture.small_opt (MEvent.Get.picture event)) in
  let  date = BatOption.map Date.to_timestamp (MEvent.Get.date event) in

  Asset_Event_PickerLine.render (object
    method name = atom # label 
    method date = BatOption.map (fun t -> (t,now)) date
    method pico = pico
  end)

let search _ key atid = 
  let eid = IEvent.of_id (IAtom.to_id atid) in
  return (Action.url UrlClient.Events.see key [ IEvent.to_string eid ])
    
let () = CAtom.register ~render ~search `Event
