(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let text ~label ?(left=false) ?detail seed parse = 
  OhmForm.wrap ".joy-fields"
    (Asset_EliteForm_Input.render (object 
      method kind   = "text" 
      method css    = "" 
      method detail = detail
      method left   = left
    end))
    (OhmForm.string
       ~field:"input" 
       ~label:(".elite-field-label label",label)
       ~error:(".elite-field-error label")
       seed parse)

let textarea ~label ?detail seed parse = 
  OhmForm.wrap ".joy-fields"
    (Asset_EliteForm_Textarea.render (object 
      method detail = detail
    end))
    (OhmForm.string
       ~field:"textarea" 
       ~label:(".elite-field-label label",label)
       ~error:(".elite-field-error label")
       seed parse)

let rich ~label ?detail seed parse = 
  OhmForm.wrap ".joy-fields"
    (Asset_EliteForm_Rich.render (object 
      method detail = detail
    end))
    (OhmForm.string
       ~field:"textarea" 
       ~label:(".elite-field-label label",label)
       ~error:(".elite-field-error label")
       seed parse)
    
let date ~label ?detail seed parse = 
  OhmForm.wrap ".joy-fields"
    (Asset_EliteForm_Date.render (object 
      method detail = detail
    end))
    (OhmForm.string
       ~field:"input[type='hidden']" 
       ~label:(".elite-field-label label",label)
       ~error:(".elite-field-error label")
       seed parse)

let picker ~label ?(left=false) ?detail ~format ?(static=[]) seed parse = 
  let render = 
    let! static = ohm $ Run.list_map (fun (value,key,html) ->
      let! html = ohm html in
      return (format.Fmt.to_json value, key, Html.to_html_string html)
    ) static in
    Asset_EliteForm_Picker.render (object 
      method detail = detail
      method left   = left
      method stat   = static 
    end)
  in
  OhmForm.wrap ".joy-fields" render
    (OhmForm.json
       ~field:"input[type='hidden']" 
       ~label:(".elite-field-label label",label)
       ~error:(".elite-field-error label")
       (fun s -> let! list = ohm $ seed s in 
		 return $ Json.of_list format.Fmt.to_json list)
       (fun f json ->
	 Util.log "Parse: %s" (Json.serialize json) ;
	 let list = 
	   try BatList.filter_map format.Fmt.of_json (Json.to_array json) 
	   with _ -> []
	 in parse f list))

let radio ~label ?detail ~format ~source seed parse = 
  OhmForm.wrap ".joy-fields"
    (Asset_EliteForm_Radio.render (object 
      method detail = detail
    end))
    (OhmForm.choice 
       ~field:".elite-field-list"
       ~label:(".elite-field-label label",label)
       ~error:(".elite-field-error label")
       ~format
       ~source
       ~multiple:false
       (fun s -> let! s = ohm (seed s) in
		 match s with 
		   | None   -> return [ ]
		   | Some x -> return [x])
       (fun i v -> let v = match v with [x] -> Some x | _ -> None in
		   parse i v))

let checkboxes ~label ?detail ~format ~source seed parse = 
  OhmForm.wrap ".joy-fields"
    (Asset_EliteForm_Radio.render (object 
      method detail = detail
    end))
    (OhmForm.choice 
       ~field:".elite-field-list"
       ~label:(".elite-field-label label",label)
       ~error:(".elite-field-error label")
       ~format
       ~source
       ~multiple:true
       seed
       parse)

let with_ok_button ~ok t = 
  OhmForm.wrap "" (Asset_EliteForm_WithOkButton.render ok) t
