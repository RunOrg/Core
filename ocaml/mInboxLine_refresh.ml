(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

let get_wall_info owner current = 

  let! fid = ohm_req_or (return None) begin 
    match current with Some info -> return (Some info.Info.Wall.id) | None ->
      match (owner : IInboxLineOwner.t) with 
	| (`Event _) as owner -> MFeed.try_by_owner owner 			      	
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
    Tbl.transact ilid begin function
      | None -> return ((), `keep) 
      | Some current -> let! wall = ohm $ get_wall_info current.Line.owner current.Line.wall in 
			let  time = 
			  List.fold_left max current.Line.time 
			    (BatList.filter_map identity [ 
			      BatOption.bind (fun w -> w.Info.Wall.last) wall ;
			    ])
			in
			let fresh = Line.({ current with wall ; time }) in
			return ((),`put fresh)
    end        
  end

let schedule ilid = 
  Run.edit_context (fun ctx -> (ctx :> O.ctx)) (schedule ilid)
