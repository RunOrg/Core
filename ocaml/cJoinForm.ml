(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module CreateFmt = Fmt.Make(struct
  type json t = <
    kind : [ `LongText 
	   | `Textarea
	   | `PickOne
	   | `PickMany
	   | `Date 
	   | `Profile ] ;
    text : string ;
    req : bool ;
    pick : string list ;
    prof : string
  >
end)

module EditFmt = Fmt.Make(struct
  type json t = <
    text : string ;
    req : bool ;
  >
end)

module ArgFmt = Fmt.Make(struct
  type json t = 
    [ `View of int
    | `Edit of int * EditFmt.t
    | `Form of int
    | `Delete of int
    ]
end)

let profile_fields = 
  [ "Phone"    , `Phone     ; "Address"  , `Address   ;
    "Cellphone", `Cellphone ; "Zipcode"  , `Zipcode   ;
    "Birthdate", `Birthdate ; "City"     , `City      ;
    "Gender"   , `Gender    ; "Country"  , `Country   ;
  ]

let box access gid inner =
 
  (* Check whether group exists and can be managed by the user. *)

  let  error = inner (return ignore) in

  let! group = ohm_req_or error $ O.decay (MGroup.try_get access gid) in 
  let! group = ohm_req_or error $ O.decay (MGroup.Can.admin group) in

  (* Extract fields in (idx, (Field.t, Flat.t)) format. References to 
     fields in destroyed groups are automatically hidden. *)

  let  fields = MGroup.Fields.get group in 
  let  fields = BatList.mapi (fun i f -> (i,f)) fields in 
  let! fields = ohm (Run.list_filter (fun (i,f) ->
    let! flat = ohm_req_or (return None)
      (O.decay (MGroup.Fields.flat (MGroup.Get.id group) f)) in
    return (Some (i,(f,flat))) 
  ) fields) in

  (* Determine if a field is local or global. *)
  let extern = function 
    | `Local _ -> false
    | `Profile _ 
    | `Import _ -> true
  in

  (* Rendering a field, using the same data type as the fields list *)

  let render_field edit (idx,(f,flat)) = 

    let choices list = 
      Run.list_filter (fun t ->
	let! text = ohm $ TextOrAdlib.to_string t in
	if text = "" then return None else return (Some text) 
      ) list 
    in

    let  field = MJoinFields.Flat.collapse flat in 

    let! label = ohm (TextOrAdlib.to_string (field # label)) in
    Asset_JoinForm_List_Field.render (object
      method extern   = extern f
      method label    = label
      method required = field # required
      method edit     = match field # edit with 
	| `LongText      -> Asset_JoinForm_List_Longtext.render ()
	| `Textarea      -> Asset_JoinForm_List_Textarea.render ()
	| `Date          -> Asset_JoinForm_List_Date.render ()
	| `Checkbox      -> Asset_JoinForm_List_Checkbox.render ()
	| `PickOne  list -> Asset_JoinForm_List_Pickone.render (choices list)
	| `PickMany list -> Asset_JoinForm_List_Pickmany.render (choices list)
      method endpoint = JsCode.Endpoint.to_json 
	(OhmBox.reaction_endpoint edit ())
    end)      
  in

  (* A reaction responsible for editing individual fields *)

  let! edit = O.Box.react Fmt.Unit.fmt begin fun () json edit res -> 
        
    let! arg = req_or (return res) (ArgFmt.of_json_safe json) in

    let get idx = req_or (return res) begin
      try Some (List.assoc idx fields)
      with Not_found -> None 
    end in 

    match arg with 
      | `Form idx -> 

	let! field, flat = get idx in 

	let collapsed = MJoinFields.Flat.collapse flat in 
	
	(* We need to pop up the edit form! *)
	let! label = ohm (TextOrAdlib.to_string (collapsed # label)) in
	let! html = ohm $ Asset_JoinForm_Edit.render (object
	  method extern   = extern field
	  method req      = collapsed # required
	  method text     = label
	  method endpoint = JsCode.Endpoint.to_json
	    (OhmBox.reaction_endpoint edit ())
	end) in
	
	return $ Action.json [ "edit", Html.to_json html ] res    

      | `View idx ->

	let! field, flat = get idx in 

	(* We need to restore the field HTML: render it and send it back. *)
	let! html = ohm $ render_field edit (idx,(field,flat)) in 
	return $ Action.json [ "field", Html.to_json html ] res 

      | `Delete idx -> 
	
	(* Remove the field from the list of fields. The client will
	   also remove it from the client-side list. *)
	
	let fields = BatList.filter_map (fun (i,(f,_)) -> 
	  if i = idx then None else Some f
	) fields in 
	
	let! () = ohm (O.decay (MGroup.Fields.set group fields)) in      
	return res

      | `Edit (idx,data) -> 
	
	let! field, flat = get idx in 
	(* Edit the field using the sent data *)     
	let field = match field with 
	  | `Local f -> `Local (object
	    method edit = f # edit
	    method name = f # name
	    method required = data # req
	    method label = `text (data # text) 
	  end)
	  | `Profile (req,what) -> `Profile (data # req, what)
	  | `Import (req,gid,name) -> `Import (data # req, gid, name) 
	in
	let fields = List.map (fun (i,(f,_)) -> if i = idx then field else f) fields in 
	
	let! flat' = ohm $ O.decay (MGroup.Fields.flat (MGroup.Get.id group) field) in
	let  flat  = BatOption.default flat flat' in
	
	let! () = ohm (O.decay (MGroup.Fields.set group fields)) in      
	let! html = ohm $ render_field edit (idx,(field,flat)) in 
	return $ Action.json [ "field", Html.to_json html ] res 
	  
  end in 

  (* Reaction that creates a new field. *)

  let! create = O.Box.react Fmt.Unit.fmt begin fun _ json _ res ->
    
    let! data = req_or (return res) $ CreateFmt.of_json_safe json in 
    
    let name = Id.gen () |> Id.str in
    
    let pick = List.map (fun t -> `text t) (data # pick) in
    let what = match data # kind with 
      | `LongText -> `Local `LongText
      | `Textarea -> `Local `Textarea
      | `Date     -> `Local `Date
      | `PickOne  -> `Local (`PickOne pick)
      | `PickMany -> `Local (`PickMany pick)
      | `Profile  -> `Profile
    in
	
    let field = match what with 
      | `Local edit -> `Local (object
	method name     = name
	method label    = `text data # text
	method required = data # req
	method edit     = edit 	  
      end)
      | `Profile -> let f = try List.assoc (data # prof) profile_fields with _ -> `Cellphone in
		    `Profile (data # req, f)
    in

    let fields = (List.map (snd |- fst) fields) @ [field] in
    
    let! () = ohm (O.decay (MGroup.Fields.set group fields)) in

    let   idx = List.length fields - 1 in
    let! flat = ohm_req_or (return res) $
      O.decay (MGroup.Fields.flat (MGroup.Get.id group) field) in
      
    let! html = ohm $ render_field edit (idx,(field,flat)) in 

    return $ Action.json [ "field", Html.to_json html ] res

  end in 

  (* Rendering the actual box with the provided fields. The create-new-field 
     link only appears if the number of fields has not maxed out yet. *)

  let render = 

    let! list = ohm $ Run.list_map (render_field edit) fields in 

    Asset_JoinForm_List.render (object
      method list = Html.concat list 
      method form = if List.length fields < MGroup.Fields.max then 
	  Some (object
	    method profile = List.map (fun (v,l) -> (object
	      method value = v
	      method label = l
	    end)) profile_fields
	    method submit = JsCode.Endpoint.to_json 
	      (OhmBox.reaction_endpoint create ())
	  end)
	else
	  None
    end)

  in
 
  inner render
