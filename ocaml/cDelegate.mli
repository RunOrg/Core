(* © 2013 RunOrg *)

type delegator = <
  get : IAvatar.t list ;
  set : IAvatar.t list -> unit O.run
>

val picker : 
     ([`Help|`Submit] -> O.i18n)
  -> string
  -> [<`IsToken|`IsAdmin] CAccess.t
  -> delegator
  -> (Ohm.Html.writer O.run -> O.Box.result O.boxrun) 
  -> O.Box.result O.boxrun

val list : 
     ?admins:bool
  -> ([`Help|`Submit] -> O.i18n)
  -> string option
  -> [<`IsToken|`IsAdmin] CAccess.t
  -> delegator 
  -> (Ohm.Html.writer O.run -> O.Box.result O.boxrun) 
  -> O.Box.result O.boxrun
