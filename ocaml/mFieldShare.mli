(* © 2013 RunOrg *)

include Ohm.Fmt.FMT with type t = 
  [ `basic      (* Picture, name *)
  | `birth     
  | `email     
  | `phone     
  | `cellphone 
  | `address   
  | `city       (* And zipcode *)
  | `country    
  | `gender     ]

val default : t list option
