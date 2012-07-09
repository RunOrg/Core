(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render kind profile status status_edit = 
  
  let gender = None in
  
  let action ?invite ?user ?admin green label = object
    method label = AdLib.write label
    method green = green 
    method url = OhmBox.reaction_json status_edit (object
      method invite = invite
      method user   = user
      method admin  = admin 
    end)
  end in
  
  let actions = match status with 
    | `NotMember -> 
      if kind = `Event then 
	            [ action ~invite:true ~user:false ~admin:true  true  `Join_Edit_Event_Invite ;
		      action               ~user:true  ~admin:true  false `Join_Edit_Event_Add ]
      else
	            [ action              ~user:true  ~admin:true  true  `Join_Edit_Add ] 
    | `Declined  -> []
    | `Pending   -> [ action                          ~admin:true  true  `Join_Edit_Accept ;
		      action                          ~admin:false false `Join_Edit_Decline ]
    | `Invited   -> 
      if kind = `Event then 
	            [ action              ~user:true  ~admin:true  false `Join_Edit_Event_Add ] 
      else
	            [ action              ~user:true  ~admin:true  false `Join_Edit_Add ] 
    | `Unpaid    -> []
    | `Member    -> [ action                          ~admin:false false `Join_Edit_Remove ]
  in
  
  let status_tag = match status with 
    | `Unpaid   -> Some (`Unpaid gender)
    | `Pending  -> Some (`Pending gender)
    | `Invited  -> Some (`Invited gender)
    | `Member   -> Some (`GroupMember gender)
    | `Declined -> Some (`Declined gender)
    | `NotMember -> None
  in
  
  Asset_Join_Edit_Top.render (object
    method picture = Some (profile # pic)
    method name    = profile # name
    method status  = status_tag
    method actions = actions
  end)
