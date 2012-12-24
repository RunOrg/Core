(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module View = MInboxLine_view

let schedule = O.async # define "inbox-line-push" Fmt.( IInboxLine.fmt * Int.fmt ) 
  begin fun (ilid,push) ->
    let! current = ohm_req_or (return ()) $ Tbl.get ilid in
    if current.Line.push <> push then return () else
      return () 
  end 

let schedule ilid push = 
  O.decay (schedule ~delay:30.0 (ilid,push))
