(* © 2013 RunOrg *)

val box :
     [`Group|`Event|`Forum|`Discussion] option
  -> 'any CAccess.t 
  -> [`Read] MFeed.t option -> O.Box.result O.boxrun
