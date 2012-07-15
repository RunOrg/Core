(* © 2012 RunOrg *)

val box :
     [ `Group | `Event | `Forum ]
  -> (string -> string) 
  -> string
  -> 'any CAccess.t 
  -> [`Admin] IGroup.id
  -> (Ohm.Html.writer O.boxrun -> Ohm.Html.writer O.boxrun)
  -> O.Box.result O.boxrun
