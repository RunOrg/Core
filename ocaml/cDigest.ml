(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

let () = 
  let! uid = Sig.listen MDigest.send in 
  return () 
