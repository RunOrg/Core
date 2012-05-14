(* © 2012 RunOrg *)

open Ohm

include Fmt.Make(struct
  type json t = [ `basic     "b" (* Picture, name *)
  	        | `birth     "i"
	        | `email     "e"
	        | `phone     "p"
	        | `cellphone "c"
	        | `address   "a"
	        | `city      "z" (* And zipcode *)
	        | `country   "n" 
	        | `gender    "g" ]
end)

let default = Some [`basic]

