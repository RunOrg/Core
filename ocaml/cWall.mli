(* © 2012 RunOrg *)

val box :
     [`Group|`Event|`Forum] option
  -> 'any CAccess.t 
  -> [`Read] MFeed.t option -> O.Box.result O.boxrun
