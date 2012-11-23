(* © 2012 RunOrg *)

val picker : 
     [`Event|`Group|`Forum]
  -> string
  -> [<`IsToken|`IsAdmin] CAccess.t
  -> [`Admin] MEntity.t
  -> (Ohm.Html.writer O.run -> O.Box.result O.boxrun) 
  -> O.Box.result O.boxrun

val list : 
     [`Event|`Group|`Forum]
  -> string option
  -> [<`IsToken|`IsAdmin] CAccess.t
  -> [`Admin] MEntity.t
  -> (Ohm.Html.writer O.run -> O.Box.result O.boxrun) 
  -> O.Box.result O.boxrun
