(* © 2012 RunOrg *)

val splash : 
     string
  -> Ohm.Html.writer O.run list
  -> Ohm.Action.response
  -> Ohm.Action.response O.run

val core :
     ?deeplink:bool 
  -> O.i18n
  -> Ohm.Html.writer O.run
  -> Ohm.Action.response
  -> Ohm.Action.response O.run
