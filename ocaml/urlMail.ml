(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let unsubscribe, def_unsubscribe = O.declare O.core "mail/unsubscribe" 
  (A.rr IUser.arg A.string) 

let signupConfirm, def_signupConfirm = O.declare O.core "c"
  (A.rr IUser.arg A.string)

let passReset, def_passReset = O.declare O.core "p"
  (A.rr IUser.arg A.string)
