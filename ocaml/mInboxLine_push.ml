(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module View = MInboxLine_view

let access_of_owner = function 
  | `Event eid -> let! event = ohm_req_or (return None) $ MEvent.get eid in 
		  return $ Some (MEvent.Get.iid event, 
				 MEvent.Satellite.access event (`Wall `Read))

module LoopFmt = Fmt.Make(struct
  type json t = (IInboxLine.t * IAvatar.t option * IInstance.t * MAccess.t) 
end)

let loop = 
  let count = 10 in
  let loop, def = O.async # declare "inbox-line-push-loop" LoopFmt.fmt in
  def begin fun (ilid, start, iid, access) ->
    let  biid = IInstance.Assert.bot iid in 
    let! line = ohm_req_or (return ()) $ Tbl.get ilid in 
    let! aids, next = ohm $ MReverseAccess.reverse_async biid ?start ~count [access] in
    let! () = ohm $ Run.list_iter (fun aid -> View.update ilid aid line) aids in 
    if next = None then return () else 
      loop (ilid, next, iid, access) 
  end ;
  fun ilid access iid -> 
    loop (ilid, None, iid, access)

let schedule = O.async # define "inbox-line-push" Fmt.( IInboxLine.fmt * Int.fmt ) 
  begin fun (ilid,push) ->
    let! line = ohm_req_or (return ()) $ Tbl.get ilid in
    if line.Line.push <> push then return () else
      let! iid, access = ohm_req_or (return ()) $ access_of_owner line.Line.owner in 
      loop ilid access iid 
  end 

let schedule ilid push = 
  O.decay (schedule ~delay:30.0 (ilid,push))
