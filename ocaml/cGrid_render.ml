(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let get_field = function
  | `Group (gid,`Field name) ->
    let! group = ohm_req_or (return None) $ MGroup.naked_get gid in  
    let fields = MGroup.Fields.get group in 
    let has_name f = f # name = name in
    return (try Some (List.find has_name fields) with _ -> None)
  | _ -> return None 
    
let format_picker json field =       
  match field # edit with 
    | `PickOne  list ->
      let n    = 
	match json with 
	  | Json.Int i -> i
	  | Json.Array (Json.Int i :: _) -> i
	  | _ -> -1 
      in 
      begin 
	try let! text = ohm $ TextOrAdlib.to_string (List.nth list n) in
	    return [text] 
	with _ -> return [] 
      end
	
    | `PickMany list ->
      let a = try Json.to_list Json.to_int json with _ -> [] in 
      let text n = 
	try let! text = ohm $ TextOrAdlib.to_string (List.nth list n) in
	    return $ Some text 
	with _ -> return None
      in
      Run.list_filter text a
	
    | `LongText
    | `Textarea
    | `Date
    | `Checkbox -> return []
      
let empty : Html.writer O.boxrun = return ignore
  
let cell url gender field json = function 
  | `Text -> let str = BatOption.default "" (Fmt.String.of_json_safe json) in
	     Asset_Grid_Text.render str
  | `DateTime
  | `Date
  | `Age       -> let! now  = ohmctx (#time) in
		  let! time = req_or empty (Fmt.Float.of_json_safe json) in
		  Asset_Grid_Date.render (time,now)
  | `Status -> let! status = req_or empty (MMembership.Status.of_json_safe json) in		
	       let! key = req_or empty begin match status with 
		 | `NotMember -> None
		 | `Unpaid -> Some (`Unpaid gender)
		 | `Pending -> Some (`Pending gender)
		 | `Invited -> Some (`Invited gender)
		 | `Member -> Some (`GroupMember gender)
		 | `Declined -> Some (`Declined gender)
	       end in
	       Asset_Status_Tag.render key
  | `Checkbox -> let checked = json = Json.Bool true in 
		 Asset_Grid_Checked.render checked
  | `PickOne -> let! field = ohm_req_or empty field in 
		let! items = ohm $ format_picker json field in 
		Asset_Grid_Text.render (String.concat ", " items)
  | `Full -> let! info = req_or empty $ MAvatarGridEval.FullProfile.of_json_safe json in
	     Asset_Grid_FullInfo.render (object 
	       method info = info 
	       method url  = url 
	     end)

