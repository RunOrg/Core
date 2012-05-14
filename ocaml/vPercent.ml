(* © 2012 RunOrg *)

let compute total = 
  let multiplier = 100. /. float_of_int (max total 1) in
  fun count ->
    multiplier *. (float_of_int count) 
