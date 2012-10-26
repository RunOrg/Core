(* © 2012 RunOrg *)

let test = IWhite.of_string "test"

let all = [
  test ;
]

let represent = function
  | None -> `RunOrg 
  | Some id -> match IWhite.to_string id with 
      | "test" -> `Test 
      | other -> let error = "Unknown white id #" ^ other in
		 Ohm.Util.log "%s" error ;
		 raise Not_found
		   
let domain id = match represent (Some id) with 
  | `RunOrg -> "runorg.com"
  | `Test -> "test.local" 

let white = function 
  | "test.local" -> Some test
  | _ -> None

let slice_domain domain = 
  try let dot1 = String.rindex domain '.' in
      let prefix, domain = 
	try let dot2 = String.rindex_from domain (dot1 - 1) '.' in
	    Some (String.sub domain 0 dot2), 
	    String.sub domain (dot2 + 1) (String.length domain - dot2 - 1)
	with _ -> None, domain 
      in
      prefix, white domain      
  with _ -> None, None

let the id = match represent id with 
  | `RunOrg -> "RunOrg"
  | `Test   -> "la Fédération de Test"

let of_the id = match represent id with 
  | `RunOrg -> "de RunOrg"
  | `Test -> "de la Fédération de Test"

let email id = match represent id with 
  | `RunOrg -> "contact@runorg.com"
  | `Test -> "contact+test@runorg.com"
