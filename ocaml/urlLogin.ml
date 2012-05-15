(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let login,       def_login       = O.declare O.secure "login"        (A.o IInstance.arg)
let post_login,  def_post_login  = O.declare O.secure "login/post"   (A.o IInstance.arg)
let post_signup, def_post_signup = O.declare O.secure "login/signup" (A.o IInstance.arg)
let logout,      def_logout      = O.declare O.secure "logout"       A.none
