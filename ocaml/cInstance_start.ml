(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

let get ctx = 
  
  (* Fetch the current status *)
  let! admin = req_or (return None) $ IIsIn.Deduce.is_admin (ctx # myself) in
  let  iid   = IIsIn.instance admin in 
  let! data  = ohm $ MStart.get ~force:true iid in 
  let! vert  = ohm $ MVertical.get_cached (ctx # instance # ver) in
  let  steps = vert # steps in
  let! next  = req_or (return None) (MStart.next_step data steps) in
  let  nth   = MStart.step_number next steps in 
  return $ Some (CStart.get_next_step nth ctx next)
	  
let hints ctx = 
  List.map (fun k -> k, CStart.get_hint ctx k) 
    [ `InviteMembers ;
      `AddPicture ;
      `WritePost ;
      `CreateEvent ;
      `Broadcast ;
      `InviteNetwork ;
      `Buy ;     
      `AGInvite ;
      `CreateAG
    ]
    
