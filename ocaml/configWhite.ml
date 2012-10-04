(* © 2012 RunOrg *)

let test = IWhite.of_string "test"

let all = [
  test ;
]

let domain id = match IWhite.to_string id with 
  | "test" -> "test.local" 
  | other -> let error = "Unknown white id #" ^ other in
	     Ohm.Util.log "%s" error ;
	     assert false
