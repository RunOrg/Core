(* © 2012 RunOrg *)

let test  = IWhite.of_string "test"
let ffbad = IWhite.of_string "ffbad"
let fscf  = IWhite.of_string "fscf"
let innov = IWhite.of_string "innov"

let all = [
  test ;
  ffbad ; 
  fscf ;
  innov ;
]

type t = 
  [ `RunOrg
  | `Test
  | `FFBAD
  | `FSCF
  | `Innov
  ]

let represent = function
  | None -> `RunOrg 
  | Some id -> match IWhite.to_string id with 
      | "test" -> `Test 
      | "ffbad" -> `FFBAD
      | "fscf" -> `FSCF
      | "innov" -> `Innov
      | other -> let error = "Unknown white id #" ^ other in
		 Ohm.Util.log "%s" error ;
		 raise Not_found
		   
let domain id = match represent (Some id) with 
  | `RunOrg -> "runorg.com"
  | `Test -> "test.local" 
  | `FFBAD -> "ffbad.fr"
  | `FSCF -> "fscf.fr" (* TODO: find a domain *)
  | `Innov -> "my-innovation.org" 

let white = function 
  | "test.local" -> Some test
  | "ffbad.fr" -> Some ffbad
  | "fscf.fr" -> Some fscf
  | "my-innovation.org" -> Some innov
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

let name id = match represent id with
  | `RunOrg -> "RunOrg"
  | `Test   -> "Fédération de Test"
  | `FFBAD  -> "Fédération Française de Badminton"
  | `FSCF   -> "Fédération Sportive et Culturelle de France"
  | `Innov  -> "My Innovation"

let the id = match represent id with 
  | `RunOrg -> "RunOrg"
  | `Test   -> "la Fédération de Test"
  | `FFBAD  -> "la Fédération Française de Badminton"
  | `FSCF   -> "la Fédération Sportive et Culturelle de France"
  | `Innov  -> "My Innovation"

let of_the id = match represent id with 
  | `RunOrg -> "de RunOrg"
  | `Test   -> "de la Fédération de Test"
  | `FFBAD  -> "de la Fédération Française de Badminton"
  | `FSCF   -> "de la Fédération Sportive et Culturelle de France"
  | `Innov  -> "de My Innovation"

let email id = match represent id with 
  | `RunOrg -> "contact@runorg.com"
  | `Test   -> "contact+test@runorg.com"
  | `FFBAD  -> "contact@ffbad.fr" (* TODO: find an address *) 
  | `FSCF   -> "contact@fscf.fr" (* TODO: find an address *)
  | `Innov  -> "contact@my-innovation.com" (* TODO : find an address *)

let no_reply id = match represent id with
  | `RunOrg -> "no-reply@runorg.com"
  | `Test   -> "no-reply+test@runorg.com"
  | `FFBAD  -> "no-reply@ffbad.fr" 
  | `FSCF   -> "no-reply@fscf.fr"
  | `Innov  -> "no-reply@my-innovation.com" 

let short id = match represent id with 
  | `RunOrg -> "RunOrg"
  | `Test   -> "FdT"
  | `FFBAD  -> "FFBAD"
  | `FSCF   -> "FSCF"
  | `Innov  -> "My Innovation"

let favicon id = match represent id with
  | `RunOrg -> "/public/favicon.ico"
  | `Test   -> "/ffbad-favicon.ico"
  | `FFBAD  -> "/ffbad-favicon.ico"
  | `FSCF   -> "/fscf-favicon.ico"
  | `Innov  -> "/myInnovation-favicon.ico"

let default_vertical id = match represent id with 
  | `RunOrg -> `Simple
  | `Test   -> `Simple
  | `FFBAD  -> `Badminton
  | `FSCF   -> `Simple (* TODO: find a vertical *)
  | `Innov  -> `Simple (* TODO: find a vertical *)
