(* © 2012 RunOrg *)

let test   = IWhite.of_string "test"
let ffbad  = IWhite.of_string "ffbad"
let fscf   = IWhite.of_string "fscf"
let innov  = IWhite.of_string "innov"
let m2014  = IWhite.of_string "m2014"
let clichy = IWhite.of_string "clichy"
let alfort = IWhite.of_string "alfort"

let all = [
  test ;
  ffbad ; 
  fscf ;
  innov ;
  m2014 ;
  clichy ; 
  alfort ; 
]

type t = 
  [ `RunOrg
  | `Test
  | `FFBAD
  | `FSCF
  | `M2014
  | `Clichy
  | `Alfort 
  | `Innov
  ]

let represent = function
  | None -> `RunOrg 
  | Some id -> match IWhite.to_string id with 
      | "test" -> `Test 
      | "ffbad" -> `FFBAD
      | "fscf" -> `FSCF
      | "m2014" -> `M2014
      | "innov" -> `Innov
      | "clichy" -> `Clichy
      | "alfort" -> `Alfort 
      | other -> let error = "Unknown white id #" ^ other in
		 Ohm.Util.log "%s" error ;
		 raise Not_found
		   
let domain id = match represent (Some id) with 
  | `RunOrg -> "runorg.com"
  | `Test -> "test.local" 
  | `FFBAD -> "ffbad.fr"
  | `FSCF -> "lafscf.fr"
  | `M2014 -> "m2014.fr"
  | `Innov -> "my-innovation.org" 
  | `Clichy -> "clichy.fr"
  | `Alfort -> "alfort.fr"

let white = function 
  | "test.local" -> Some test
  | "ffbad.fr" -> Some ffbad
  | "lafscf.fr" -> Some fscf
  | "m2014.fr" -> Some m2014
  | "my-innovation.org" -> Some innov
  | "clichy.fr" -> Some clichy
  | "alfort.fr" -> Some alfort 
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
  | `M2014  -> "M2014.fr"
  | `Clichy -> "Clichy"
  | `Alfort -> "Alfortville"
  | `Innov  -> "My Innovation"

let the id = match represent id with 
  | `RunOrg -> "RunOrg"
  | `Test   -> "la Fédération de Test"
  | `FFBAD  -> "la Fédération Française de Badminton"
  | `FSCF   -> "la Fédération Sportive et Culturelle de France"
  | `M2014  -> "M2014.fr" 
  | `Clichy -> "Clichy"
  | `Alfort -> "Alfortville"
  | `Innov  -> "My Innovation"

let of_the id = match represent id with 
  | `RunOrg -> "de RunOrg"
  | `Test   -> "de la Fédération de Test"
  | `FFBAD  -> "de la Fédération Française de Badminton"
  | `FSCF   -> "de la Fédération Sportive et Culturelle de France"
  | `M2014  -> "de M2014.fr"
  | `Clichy -> "de Clichy"
  | `Alfort -> "d'Alfortville"
  | `Innov  -> "de My Innovation"

let email id = match represent id with 
  | `RunOrg -> "contact@runorg.com"
  | `Test   -> "contact+test@runorg.com"
  | `FFBAD  -> "contact@ffbad.fr" (* TODO: find an address *) 
  | `FSCF   -> "contact@lafscf.fr" (* TODO: find an address *)
  | `M2014  -> "contact@m2014.fr"
  | `Clichy -> "contact@clichy.fr" (* TODO: find an address *)
  | `Alfort -> "contact@alfort.fr" (* TODO: find an address *) 
  | `Innov  -> "contact@my-innovation.com" (* TODO : find an address *)

let no_reply id = match represent id with
  | `RunOrg -> "no-reply@runorg.com"
  | `Test   -> "no-reply+test@runorg.com"
  | `FFBAD  -> "no-reply@ffbad.fr" 
  | `FSCF   -> "no-reply@lafscf.fr"
  | `M2014  -> "no-reply@m2014.fr"
  | `Clichy -> "no-reply@clichy.fr"
  | `Alfort -> "no-reply@alfort.fr"
  | `Innov  -> "no-reply@my-innovation.com" 

let short id = match represent id with 
  | `RunOrg -> "RunOrg"
  | `Test   -> "FdT"
  | `FFBAD  -> "FFBAD"
  | `FSCF   -> "FSCF"
  | `M2014  -> "M2014"
  | `Clichy -> "Clichy"
  | `Alfort -> "Alfortville"
  | `Innov  -> "My Innovation"

let favicon id = match represent id with
  | `RunOrg -> "/public/favicon.ico"
  | `Test   -> "/ffbad-favicon.ico"
  | `FFBAD  -> "/ffbad-favicon.ico"
  | `FSCF   -> "/fscf-favicon.ico"
  | `M2014  -> "/m2014-favicon.ico"
  | `Innov  -> "/myInnovation-favicon.ico"
  | `Clichy -> "/clichy-favicon.ico"
  | `Alfort -> "/alfort-favicon.ico"

let default_vertical id = match represent id with 
  | `RunOrg -> `Simple
  | `Test   -> `Simple
  | `FFBAD  -> `Badminton
  | `M2014  -> `Campaigns
  | `Clichy -> `Simple
  | `Alfort -> `Simple
  | `FSCF   -> `Simple (* TODO: find a vertical *)
  | `Innov  -> `Simple (* TODO: find a vertical *)
