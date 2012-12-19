(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module ByOwner = MInboxLine_byOwner

let () = 
  let! eid  = Sig.listen MEvent.Signals.on_bind_inboxLine in
  let! ilid = ohm $ ByOwner.get_or_create (`Event eid) in 
  let  ()  = Util.log "Binding inbox line for %s -> %s" (IEvent.to_string eid) (IInboxLine.to_string ilid) in
  return () 
