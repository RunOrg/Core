(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module F = MProfileForm
  
let body access aid me = 

  Asset_Client_PageNotFound.render ()
