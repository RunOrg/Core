(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let unsubscribe, def_unsubscribe = O.declare O.core "mail/unsubscribe" 
  (A.ro IUser.arg IInstance.arg) 

let post_unsubscribe, def_post_unsubscribe = O.declare O.core "mail/unsubscribe/post"
  (A.rro IUser.arg A.string IInstance.arg)
 
let signupConfirm, def_signupConfirm = O.declare O.core "c"
  (A.rr IUser.arg A.string)
