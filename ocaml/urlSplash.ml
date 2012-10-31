(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let index, _         = O.declare O.core "" (A.n A.string)  
let _    , def_index = O.declare O.core "" (A.rn A.string A.string)
let sindex, def_sindex = O.declare O.secure "" (A.n A.string) 
let contact, def_contact = O.declare O.core "post-contact" A.none
