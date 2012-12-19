(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

let () = 
  let! eid = Sig.listen MEvent.Signals.on_bind_inboxLine in
  let  ()  = Util.log "Binding inbox line for %s" (IEvent.to_string eid) in
  return () 
