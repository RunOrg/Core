(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module ByOwner = MInboxLine_byOwner

let refresh = O.async # define "inbox-line-refresh" IInboxLine.fmt 
  begin fun ilid -> 
    let  ()  = Util.log "Refresh InboxLine %s" (IInboxLine.to_string ilid) in
    return ()       
  end

let () = 
  let! eid  = Sig.listen MEvent.Signals.on_bind_inboxLine in
  let! ilid = ohm $ ByOwner.get_or_create (`Event eid) in 
  refresh ilid
