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

  let choices list = 
    Run.list_filter (fun t ->
      let! text = ohm $ TextOrAdlib.to_string t in
      if text = "" then return None else return (Some text) 
    ) list 
  in

  let render_field field = 
    let! label = ohm (TextOrAdlib.to_string (field # label)) in
    return (object
      method name     = field # name
      method label    = label
      method required = field # required
      method edit     = match field # edit with 
	| `LongText -> Asset_JoinForm_List_Longtext.render ()
	| `Textarea -> Asset_JoinForm_List_Textarea.render ()
	| `Date     -> Asset_JoinForm_List_Date.render ()
	| `Checkbox -> Asset_JoinForm_List_Checkbox.render ()
	| `PickOne list -> Asset_JoinForm_List_Pickone.render (choices list)
	| `PickMany list -> Asset_JoinForm_List_Pickmany.render (choices list)
    end)      
  in

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

    let! data = ohm $ render_field field in 
    let! html = ohm $ Asset_JoinForm_List_Field.render data in

    return $ Action.json [ "field", Html.to_json html ] res

  end in 

  let render = 

    let! fields = ohm begin
      let! group = ohm_req_or (return []) $ MGroup.naked_get gid in 
      return (MGroup.Fields.get group) 
    end in 

    let! list = ohm $ Run.list_map render_field fields in 

    Asset_JoinForm_List.render (object
      method list = list 
      method form = (object
	method submit = JsCode.Endpoint.to_json 
	  (OhmBox.reaction_endpoint create ())
      end)
    end)

  in
 
  inner render
