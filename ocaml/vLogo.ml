(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render owid = 
  match ConfigWhite.represent owid with 
    | `RunOrg -> Asset_Logo_Runorg.render ()
    | `Test   -> Asset_Logo_Ffbad.render () 
    | `FFBAD  -> Asset_Logo_Ffbad.render () 
    | `FSCF   -> Asset_Logo_Fscf.render () 
