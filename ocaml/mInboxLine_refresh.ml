(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

let schedule = O.async # define "inbox-line-refresh" IInboxLine.fmt 
  begin fun ilid -> 
    let  ()  = Util.log "Refresh InboxLine %s" (IInboxLine.to_string ilid) in
    return ()       
  end

let schedule ilid = 
  Run.edit_context (fun ctx -> (ctx :> O.ctx)) (schedule ilid)
