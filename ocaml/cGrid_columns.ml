(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Grid    = MAvatarGrid

type profile_label = 
  [ `Address
  | `Birthdate
  | `Cellphone
  | `City
  | `Country
  | `Email
  | `Firstname
  | `Fullname
  | `Gender
  | `Lastname
  | `Phone
  | `Zipcode ]

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

module RenameFmt = Fmt.Make(struct
  type json t = ( int * string )
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

  (* Rename a column *)

  let! rename = O.Box.react Fmt.Unit.fmt begin fun () json _ res ->
    let  fail = return res in 
    let! idx, name = req_or (return res) (RenameFmt.of_json_safe json) in
    let! ()  = true_or fail (idx > 0) in
    let columns = BatList.mapi (fun i c -> 
      if i = idx then MAvatarGridColumn.({ c with label = `text name }) 
      else c
    ) columns in 
    let! () = ohm $ O.decay (Grid.MyGrid.set_columns lid columns) in
    return res    
  end in 

  (* Delete a column *)

  let! del = O.Box.react Fmt.Unit.fmt begin fun () json _ res ->
    let fail = return res in 
    let! idx = req_or fail (try Some (Json.to_int json) with _ -> None) in 
    let! ()  = true_or fail (idx > 0) in
    let columns = 
      columns
      |> BatList.mapi (fun i x -> (i,x)) 
      |> List.filter (fst |- ((<>) idx))
      |> List.map snd
    in
    let! () = ohm $ O.decay (Grid.MyGrid.set_columns lid columns) in
    return res
  end in 

  (* Edit a column *)

  let! edit = O.Box.react Fmt.Unit.fmt begin fun () json _ res ->

    let fail = 
      let! html = ohm (Asset_Grid_Edit_Locked.render ()) in
      return $ Action.json [ "form", Html.to_json html ] res 
    in

    let! idx = req_or fail (try Some (Json.to_int json) with _ -> None) in
    let! () = true_or fail (idx > 0) in
    
    let! col = req_or fail (try Some (List.nth columns idx) with _ -> None) in 
    let! name = ohm (TextOrAdlib.to_string (col.MAvatarGridColumn.label)) in

    let! from, srcname = ohm begin 

      let p x = 
	let! from    = ohm (AdLib.get `Grid_Source_Profile_Short) in
	let! srcname = ohm (AdLib.get (`Grid_Source_Profile_Field x)) in
	return (from, srcname)
      in

      let group gid = 
	let  none   = AdLib.get `Grid_Source_Group_Unknown in
	let! group  = ohm_req_or none $ O.decay (MGroup.try_get access gid) in 
	match MGroup.Get.owner group with 
	  | `Entity eid -> let! entity = ohm_req_or none $ O.decay (MEntity.try_get access eid) in
			   let! entity = ohm_req_or none $ O.decay (MEntity.Can.view entity) in
			   CEntityUtil.name entity 
	  | `Event eid -> let! event = ohm_req_or none $ MEvent.view ~access eid in
			  MEvent.Get.fullname event
      in

      let g gid x = 
	let! name = ohm $ group gid in
	let! srcname = ohm $ AdLib.get (`Grid_Source_Local_Field x) in
	return (name, srcname) 
      in

      match col.MAvatarGridColumn.eval with
	| `Avatar  (_,`Name)      -> p `Fullname
	| `Profile (_,`Firstname) -> p `Firstname
	| `Profile (_,`Lastname)  -> p `Lastname
	| `Profile (_,`Email)     -> p `Email
	| `Profile (_,`Birthdate) -> p `Birthdate
	| `Profile (_,`City)      -> p `City
	| `Profile (_,`Address)   -> p `Address
	| `Profile (_,`Zipcode)   -> p `Zipcode
	| `Profile (_,`Country)   -> p `Country
	| `Profile (_,`Phone)     -> p `Phone
	| `Profile (_,`Cellphone) -> p `Cellphone
	| `Profile (_,`Gender)    -> p `Gender
	| `Profile (_,`Full)      -> p `Fullname
	| `Group (gid,`Status) -> g gid `Status
	| `Group (gid,`Date)   -> g gid `Date
	| `Group (gid,`InList) -> g gid `Status
	| `Group (gid,`Field f) -> 
	  let! fields = ohm $ O.decay (MGroup.Fields.local gid) in
	  let  name =
	    try BatList.find_map (fun field -> 
	      if field # name = f then Some (field # label) else None) fields
	    with Not_found -> `text ""
	  in
	  let! name = ohm $ TextOrAdlib.to_string name in
	  g gid (`Field name) 
    end in 

    let data = object
      method from = from
      method srcname = srcname
      method name = name
    end in

    let! html = ohm (Asset_Grid_Edit_Form.render data) in    

    return $ Action.json [ "form", Html.to_json html ] res 

  end in 

  (* Rendering a single column *)
  
  let render_column c = object
    method text = TextOrAdlib.to_string (c.MAvatarGridColumn.label)
    method edit = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint edit ()) 
    method del  = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint del ()) 
    method name = JsCode.Endpoint.to_json (OhmBox.reaction_endpoint rename ()) 
  end in 

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

    let  col = MAvatarGridColumn.({ label ; view ; eval }) in

    let  columns = columns @ [col] in
    let! () = ohm $ O.decay (Grid.MyGrid.set_columns lid columns) in

    let! html = ohm $ Asset_Grid_Edit_Column.render (render_column col) in
    let  html = Html.to_json html in 

    return $ Action.json [ "col", html ] res

  end in 

  let body = 
    let! local = ohm (MGroup.Fields.local gid)in
    let! local = ohm (local_fields local) in
    Asset_Grid_Edit.render (object
      method columns = 
	List.map render_column columns
      method profile = 
	List.map (fun k -> (object
	  method json  = Json.serialize (EvalFmt.to_json (`Profile k))
	  method label = (k :> profile_label)
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
