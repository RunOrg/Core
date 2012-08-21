(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let default ~format ~source seed parse = 
  OhmForm.wrap ".joy-fields"
    (Asset_Notify_SettingsDefault.render ())
    (OhmForm.choice 
       ~field:".elite-field-list"
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

let radio ~name ~pic ~format ~source seed parse = 
  OhmForm.wrap ".joy-fields"
    (Asset_Notify_SettingsInstance.render (object 
      method pic  = pic
      method name = name
    end))
    (OhmForm.choice 
       ~field:".elite-field-list"
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

