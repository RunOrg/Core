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
	   | `Date ] ;
    text : string ;
    req : bool ;
    pick : string list ;
  >
end)

let box access entity inner =
 
  let  gid   = MEntity.Get.group entity in
  let  error = inner (return ignore) in

  let! group = ohm_req_or error $ O.decay (MGroup.try_get access gid) in 
  let! group = ohm_req_or error $ O.decay (MGroup.Can.admin group) in

  let fields = MGroup.Fields.get group in 

  let choices list = 
    Run.list_filter (fun t ->
      let! text = ohm $ TextOrAdlib.to_string t in
      if text = "" then return None else return (Some text) 
    ) list 
  in

  let render_field edit field = 
    let! label = ohm (TextOrAdlib.to_string (field # label)) in
    return (object
      method label    = label
      method required = field # required
      method edit     = match field # edit with 
	| `LongText -> Asset_JoinForm_List_Longtext.render ()
	| `Textarea -> Asset_JoinForm_List_Textarea.render ()
	| `Date     -> Asset_JoinForm_List_Date.render ()
	| `Checkbox -> Asset_JoinForm_List_Checkbox.render ()
	| `PickOne list -> Asset_JoinForm_List_Pickone.render (choices list)
	| `PickMany list -> Asset_JoinForm_List_Pickmany.render (choices list)
      method endpoint = JsCode.Endpoint.to_json 
	(OhmBox.reaction_endpoint edit (field # name))
    end)      
  in

  let! edit = O.Box.react Fmt.String.fmt begin fun name json edit res -> 
    
    let! field = req_or (return res) begin
      try Some (List.find (fun f -> (f # name) = name) fields)
      with Not_found -> None 
    end in

    if json = Json.Null then 

      (* We need to pop up the edit form! *)
      let! html = ohm $ Asset_JoinForm_Edit.render (object
	method endpoint = JsCode.Endpoint.to_json
	  (OhmBox.reaction_endpoint edit name)
      end) in

      return $ Action.json [ "edit", Html.to_json html ] res    

    else if json = Json.Bool false then

      (* We need to restore the field. *)
      let! data = ohm $ render_field edit field in 
      let! html = ohm $ Asset_JoinForm_List_Field.render data in 
      return $ Action.json [ "field", Html.to_json html ] res 
	
    else if json = Json.String "delete" then 

      (* Remove the field from the list of fields *)
      let fields = List.filter (fun f -> (f # name) <> name) fields in
      let! () = ohm (O.decay (MGroup.Fields.set group fields)) in      
      return res

    else

      return res

  end in 

  let! create = O.Box.react Fmt.Unit.fmt begin fun _ json _ res ->
    
    let! data = req_or (return res) $ CreateFmt.of_json_safe json in 
    
    let name = Id.gen () |> Id.str in

    let field = object
      method name     = name
      method label    = `text data # text
      method required = data # req
      method edit     = let pick = List.map (fun t -> `text t) (data # pick) in
			match data # kind with 
			  | `LongText -> `LongText
			  | `Textarea -> `Textarea
			  | `Date -> `Date
			  | `PickOne -> `PickOne pick
			  | `PickMany -> `PickMany pick
    end in

    let fields = fields @ [field] in
    
    let! () = ohm (O.decay (MGroup.Fields.set group fields)) in

    let! data = ohm $ render_field edit field in 
    let! html = ohm $ Asset_JoinForm_List_Field.render data in

    return $ Action.json [ "field", Html.to_json html ] res

  end in 

  let render = 

    let! list = ohm $ Run.list_map (render_field edit) fields in 

    Asset_JoinForm_List.render (object
      method list = list 
      method form = (object
	method submit = JsCode.Endpoint.to_json 
	  (OhmBox.reaction_endpoint create ())
      end)
    end)

  in
 
  inner render
