(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let search key atid = 
  let eid = IEvent.of_id (IAtom.to_id atid) in
  Action.url UrlClient.Events.see key [ IEvent.to_string eid ]
    
let () = CAtom.register ~search `Event
