(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let () = UrlLogin.def_login begin fun req res -> return res end
