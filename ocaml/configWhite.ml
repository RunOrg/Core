(* © 2012 RunOrg *)

let test = IWhite.of_string "test"

let all = [
  test ;
]

let domain id = match IWhite.to_string id with 
  | "test" -> "test.local" 
  | other -> failwith ("Unknown white id #" ^ other) 
