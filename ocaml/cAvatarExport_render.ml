(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let tr x = TextOrAdlib.to_string (`label x)
let e    = return "" 

module Format = struct

  let gender = function 
    | Json.String "m" -> tr `Gender_Male
    | Json.String "f" -> tr `Gender_Female
    | _ -> e

  let text = function 
    | Json.String s -> return s
    | _ -> e

  let checkbox = function 
    | Json.Bool true -> tr `Yes 
    | _ -> e

  let date = function 
    | Json.Float  f -> AdLib.get (`FullDate f) 
    | Json.String s -> let! f = req_or e (MFmt.float_of_date s) in 
		       AdLib.get (`FullDate f)
    | _ -> e

  let status json = 
    let! status = req_or e (MMembership.Status.of_json_safe json) in		
    match status with 
      | `NotMember -> e
      | `Unpaid    -> AdLib.get (`Status_Unpaid None)
      | `Pending   -> AdLib.get (`Status_Pending None)
      | `Invited   -> AdLib.get (`Status_Invited None)
      | `Member    -> AdLib.get (`Status_GroupMember None)
      | `Declined  -> AdLib.get (`Status_Declined None)
	       
  let pick list = function 
    | Json.Int   i -> (try TextOrAdlib.to_string (List.nth list i) with _ -> e) 
    | Json.Array l -> let! l = ohm $ Run.list_map identity (BatList.filter_map (function
	                | Json.Int i -> (try Some (TextOrAdlib.to_string (List.nth list i)) 
			                 with _ -> None)
			| _ -> None) l)
		      in
		      return (String.concat ";" l)
    | _ -> e

end    

let get_field gid name = 
  let! fields = ohm $ MGroup.Fields.local gid in
  return 
    (try Some (List.find ((#name) |- (=) name) fields)
     with _ -> None)
    
let get_format = function
  | `Profile (_,`Gender) -> return Format.gender
  | `Profile (_,`Birthdate) -> return Format.date 
  | `Profile (_,_) -> return Format.text
  | `Avatar (_,_) -> return Format.text
  | `Group (_,`Date) -> return Format.date
  | `Group (_,`Status) -> return Format.status
  | `Group (_,`InList) -> return Format.checkbox
  | `Group (gid,`Field f) -> 
    let! field = ohm_req_or (return Format.text) (get_field gid f) in
    match field # edit with 
      | `Textarea
      | `LongText -> return Format.text
      | `Checkbox -> return Format.checkbox
      | `Date -> return Format.date
      | `PickOne  l
      | `PickMany l -> return (Format.pick l)

let cell json eval = 
  let! f = ohm (get_format eval) in 
  f json 
