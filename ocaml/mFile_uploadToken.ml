(* © 2013 RunOrg *)

open Ohm

(* The identifier of a currently pending upload. *)

type t = Id.t 

let to_string t = 
  let string = Id.to_string t in 
  string ^ "-" ^ ConfigKey.prove [ "upload" ; string ]

let of_string string = 
  try let id, proof = BatString.split string "-" in
      if ConfigKey.is_proof proof [ "upload" ; id ] then Some (Id.of_string id) 
      else None
  with _ -> None

let arg = to_string, of_string
