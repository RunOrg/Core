(* © 2012 RunOrg *)

val core :
     ?deeplink:bool 
  -> O.i18n
  -> Ohm.Html.writer O.run
  -> Ohm.Action.response
  -> Ohm.Action.response O.run
