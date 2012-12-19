(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module ByOwner = MInboxLine_byOwner
module Refresh = MInboxLine_refresh

let () = 
  let! eid  = Sig.listen MEvent.Signals.on_bind_inboxLine in
  let! ilid = ohm $ ByOwner.get_or_create (`Event eid) in 
  Refresh.schedule ilid
