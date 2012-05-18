(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let unsubscribe, def_unsubscribe = O.declare O.core "mail/unsubscribe" 
  (A.rr IUser.arg A.string) 

