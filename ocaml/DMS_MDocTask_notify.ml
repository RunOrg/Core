(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Core = DMS_MDocTask_core

include MMail.Register(struct

  include Fmt.Make(struct
    type json t = <
      what : [ `NewState    of Json.t 
	     | `SetAssigned of IAvatar.t (* Who is the new assignee ? *)
	     | `SetNotified ] ;
      uid  : IUser.t ;
      iid  : IInstance.t ;
      dtid : DMS_IDocTask.t ;
      did  : DMS_IDocument.t ; 
      from : IAvatar.t ;
    >
  end)
   
  let id = IMail.Plugin.of_string "dms-doctask"
  let iid x = Some (x # iid)
  let uid x = x # uid
  let from x = Some (x # from) 
  let solve _ = None
  let item _ = true

end)

(* React to new versions in the async process to avoid overloading 
   the web server with version queries. *)
let task = O.async # define "dms-doctask-notify" Core.Store.VersionId.fmt begin fun vid ->

  let! version = ohm_req_or (return ()) (Core.Store.get_version vid) in 
  let! before, after = ohm_req_or (return ()) (Core.Store.version_snapshot version) in
  
  let  dtid = Core.Store.version_object version in 
  let  did  = after.Core.did in
  let  iid  = after.Core.iid in 
  let! from = req_or (return ()) 
    (match (Core.Store.version_data version).MUpdateInfo.who with
    | `user (_,aid) -> Some aid
    | `preconfig -> None) in 

  let send what aid = 
    let! uid = ohm_req_or (return ()) (MAvatar.get_user aid) in
    send_one (object
      method uid = uid
      method iid = iid
      method did = did
      method dtid = dtid
      method from = from
      method what = what
    end)
  in
  
  (* If people were previously unrelated to the task, tell them that they have been 
     added to the list of notified people. If one of them is the new assignee, however, 
     do not tell them that they are also going to be notified ! *)

  let before_notified = BatPSet.of_list (
    match before.Core.assignee with 
    | None -> before.Core.notified 
    | Some aid -> aid :: before.Core.notified) in

  let after_notified = BatPSet.of_list after.Core.notified in 

  let new_notified = 
    BatPSet.filter (fun aid -> not (BatPSet.mem aid before_notified)) after_notified 
    |> (match before.Core.assignee with None -> identity | Some aid -> BatPSet.remove aid) 
    |> (fun set -> BatPSet.fold (fun a l -> a :: l) set [])
  in 
 
  let! () = ohm (Run.list_iter (send `SetNotified) new_notified) in

  (* If a new assignee was set, tell all the old notified people about it
     (but not the new ones : they don't know that there was an old one, and 
     they already received an email for this change). The new assignee should 
     be told ! *)

  let old_notified = BatPSet.fold (fun a l -> a :: l) before_notified [] in

  match after.Core.assignee with 
  | Some aid when after.Core.assignee <> before.Core.assignee -> 
    
    let notified = if List.mem aid old_notified then old_notified else aid :: old_notified in 
    Run.list_iter (send (`SetAssigned aid)) notified

  (* If the assignee remained the same, maybe the state has changed ? 
     In that case, notify about the state change instead. *)
    
  | _ -> 

    let before_state, _, _ = before.Core.state in 
    let after_state, _, _ = after.Core.state in 
    
    if before_state <> after_state then

      Run.list_iter (send (`NewState after_state)) old_notified

    (* Oh well... just a data change. Do nothing. *)

    else return () 

end

let () = 
  let! version = Sig.listen Core.Store.Signals.version_create in
  let  id = Core.Store.version_id version in 
  task id 
