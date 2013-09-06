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
    | `M2014  -> Asset_Logo_M2014.render () 
    | `Clichy -> Asset_Logo_Clichy.render ()
    | `Alfort -> Asset_Logo_Alfort.render ()  
    | `Innov  -> Asset_Logo_MyInnovation.render () 
    | `GEFeL  -> Asset_Logo_Gefel.render ()
