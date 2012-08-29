(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Grid    = MAvatarGrid

module EvalFmt = Fmt.Make(struct
  type json t = 
    [ `Profile of [ `Birthdate
		  | `City     
		  | `Address  
		  | `Zipcode  
		  | `Country  
		  | `Phone    
		  | `Cellphone
		  | `Gender   
		  ]
    | `Local of [ `Status		    
		| `Date
		| `Field of string
		]
    ]
end)

let profile_fields = 
  [ `Birthdate ;`Gender ; `Phone   ; `Cellphone ;
    `Address   ; `City  ; `Zipcode ; `Country   ]

let local_fields local = 
  let! list = ohm (Run.list_map (fun f -> 
    let! label = ohm (TextOrAdlib.to_string (f # label)) in
    return (`Field (f # name), `Field label)
  ) local) in
  return ((`Status,`Status) :: (`Date,`Date) :: list)

let box access entity render = 
  
  let fail = render (return ignore) in 

  (* Extract the AvatarGrid identifier *)

  let  draft  = MEntity.Get.draft entity in 

  let  gid = MEntity.Get.group entity in
  let! group = ohm $ O.decay (MGroup.try_get access gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.list group) in
  let  group = if draft then None else group in   
  let! group = req_or fail group in 

  let  grid  = MGroup.Get.list group in 
  let  lid   = Grid.list_id grid in
  
  let! columns = ohm $ O.decay (
    let! columns, _, _ = ohm_req_or (return []) $ Grid.MyGrid.get_list lid in    
    return columns
  ) in

  let body = 
    let! local = ohm (MGroup.Fields.local gid)in
    let! local = ohm (local_fields local) in
    Asset_Grid_Edit.render (object
      method columns = 
	List.map MAvatarGridColumn.(fun c -> TextOrAdlib.to_string c.label) columns
      method profile = 
	List.map (fun k -> (object
	  method json  = Json.serialize (EvalFmt.to_json (`Profile k))
	  method label = k
	end)) profile_fields
      method local   = 
	List.map (fun (k,l) -> (object
	  method json  = Json.serialize (EvalFmt.to_json (`Local k))
	  method label = l
	end)) local
    end)
  in

  render body
