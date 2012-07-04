(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let text ~label ?detail seed parse = 
  OhmForm.wrap ".joy-fields"
    (Asset_EliteForm_Input.render (object 
      method kind   = "text" 
      method css    = "" 
      method detail = detail
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

let with_ok_button ~ok t = 
  OhmForm.wrap "" (Asset_EliteForm_WithOkButton.render ok) t
