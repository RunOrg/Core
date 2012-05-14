(* © 2012 RunOrg *)

val layout :
     js:Ohm.JsCode.t
  -> title:Ohm.View.Context.text Ohm.View.t
  -> body:Ohm.View.Context.box Ohm.View.t
  -> O.Action.response
  -> O.Action.response

val register :
     # O.Action.controller
  -> (    Ohm.I18n.t 
       -> [ `Admin ] ICurrentUser.id
       -> O.Action.request
       -> O.Action.response 
       -> O.Action.response O.run )
  -> unit
