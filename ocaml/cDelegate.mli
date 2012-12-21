(* © 2012 RunOrg *)

type delegator = <
  get : IAvatar.t list ;
  set : IAvatar.t list -> unit O.run
>

val picker : 
     [`Event|`Group|`Forum|`ProfileView]
  -> string
  -> [<`IsToken|`IsAdmin] CAccess.t
  -> delegator
  -> (Ohm.Html.writer O.run -> O.Box.result O.boxrun) 
  -> O.Box.result O.boxrun

val list : 
     [`Event|`Group|`Forum|`ProfileView]
  -> string option
  -> [<`IsToken|`IsAdmin] CAccess.t
  -> delegator 
  -> (Ohm.Html.writer O.run -> O.Box.result O.boxrun) 
  -> O.Box.result O.boxrun
