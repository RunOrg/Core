(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

let get_wall_info owner current = 

  let! fid = ohm_req_or (return None) begin 
    match current with Some info -> return (Some info.Info.Wall.id) | None ->
      match owner with 
	| (#IFeedOwner.t) as owner -> MFeed.try_by_owner owner 			      
	| _ -> return None
  end in 

  (* Act as a bot to extract the information. 
     Extracted information is general enough to be available to all
     viewers of the inbox line.
  *)
  let fid = IFeed.Assert.bot fid in
  
  let! stats = ohm $ MItem.stats (`feed fid) in
  
  return (Some Info.Wall.({ 
    id      = IFeed.decay fid ; 
    n       = stats # n ; 
    last    = stats # last ;
    authors = stats # authors ; 
  }))
  
let schedule = O.async # define "inbox-line-refresh" IInboxLine.fmt 
  begin fun ilid -> 
    return ()       
  end

let schedule ilid = 
  Run.edit_context (fun ctx -> (ctx :> O.ctx)) (schedule ilid)
