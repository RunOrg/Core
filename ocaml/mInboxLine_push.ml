(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module View = MInboxLine_view

let access_of_owner = function 
  | `Event eid -> let! event = ohm_req_or (return None) $ MEvent.get eid in 
		  let! access = ohm (MEvent.Satellite.access event (`Wall `Read)) in
		  return $ Some (MEvent.Get.iid event, access) 				 
  | `Discussion did -> let! discn = ohm_req_or (return None) $ MDiscussion.get did in 
		       let! access = ohm (MDiscussion.Satellite.access discn (`Wall `Read)) in
		       return $ Some (MDiscussion.Get.iid discn, access) 

let loop = 
  MAvatarStream.iter "inbox-line-push-loop" IInboxLine.fmt 
    (fun ilid aid -> 
      let! line = ohm_req_or (return ()) (Tbl.get ilid) in
      View.update ilid aid line)    
    (fun _ -> return ()) 

let schedule = O.async # define "inbox-line-push" Fmt.( IInboxLine.fmt * Int.fmt ) 
  begin fun (ilid,push) ->
    let! line = ohm_req_or (return ()) $ Tbl.get ilid in
    if line.Line.push <> push then return () else
      let! iid, stream = ohm_req_or (return ()) $ access_of_owner line.Line.owner in 
      let  iid = IInstance.Assert.bot iid in
      loop iid stream ilid
  end 

let schedule ilid push = 
  (* Make sure there's something to work with *)
  let! line = ohm_req_or (return ()) $ Tbl.get ilid in 
  let! time, aid = req_or (return ()) (line.Line.last) in
  (* Notify the author immediately *)
  let! () = ohm $ View.update ilid aid line in 
  (* Wait for 30s before notifying others *)
  O.decay (schedule ~delay:30.0 (ilid,push))
