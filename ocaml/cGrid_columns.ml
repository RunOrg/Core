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

  (* Creation response *)

  let! create = O.Box.react Fmt.Unit.fmt begin fun () json _ res ->
    let  fail = return res in
    let! eval = req_or fail (EvalFmt.of_json_safe json) in 

    let with_field f def op = 
      let fields = MGroup.Fields.get group in 
      try 
	BatList.find_map (function
	  | `Local field when field # name = f -> Some (op field)
	  | _ -> None
	) fields
      with Not_found -> def
    in

    let label = match eval with 
      | `Local `Status -> `label `ParticipateFieldState
      | `Local `Date   -> `label `ParticipateFieldDateShort
      | `Local (`Field f) -> with_field f (`text "") (#label)
      | `Profile `Birthdate -> `label `Birthdate
      | `Profile `Phone     -> `label `Phone
      | `Profile `Cellphone -> `label `Cellphone
      | `Profile `Address   -> `label `Address
      | `Profile `Zipcode   -> `label `Zipcode
      | `Profile `City      -> `label `City
      | `Profile `Country   -> `label `Country
      | `Profile `Gender    -> `label `Gender
    in

    let field_view field = match field # edit with 
      | `Textarea -> `Text
      | `Date     -> `Date
      | `LongText -> `Text
      | `Checkbox -> `Checkbox
      | `PickOne _   -> `PickOne
      | `PickMany _  -> `PickOne
    in

    let view = match eval with 
      | `Local `Status -> `Status
      | `Local `Date -> `DateTime
      | `Local (`Field f) -> with_field f `Text field_view 
      | `Profile `Birthdate -> `Date
      | `Profile `Phone
      | `Profile `Cellphone
      | `Profile `Address
      | `Profile `Zipcode
      | `Profile `Country
      | `Profile `City -> `Text
      | `Profile `Gender -> `Text
    in

    let iid = access # instance # id in 
    let eval = match eval with 
      | `Local `Status -> `Group (gid, `Status)
      | `Local `Date   -> `Group (gid, `Date) 
      | `Local (`Field f) -> `Group (gid, `Field f)
      | `Profile `Birthdate -> `Profile (iid, `Birthdate)
      | `Profile `Phone     -> `Profile (iid, `Phone)
      | `Profile `Cellphone -> `Profile (iid, `Cellphone)
      | `Profile `Address   -> `Profile (iid, `Address)
      | `Profile `Zipcode   -> `Profile (iid, `Zipcode)
      | `Profile `Country   -> `Profile (iid, `Country)
      | `Profile `City      -> `Profile (iid, `City) 
      | `Profile `Gender    -> `Profile (iid, `Gender) 
    in

    let  col = MAvatarGridColumn.({ label ; show = true ; view ; eval }) in

    let  columns = columns @ [col] in
    let! () = ohm $ O.decay (Grid.MyGrid.set_columns lid columns) in

    let! html = ohm $ Asset_Grid_Edit_Column.render (TextOrAdlib.to_string label) in
    let  html = Html.to_json html in 

    return $ Action.json [ "col", html ] res

  end in 

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
      method create = JsCode.Endpoint.to_json 
	(OhmBox.reaction_endpoint create ())
    end)
  in

  render body
