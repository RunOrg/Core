(* © 2012 RunOrg *)

type item = <
  action : [`Go of string | `Do of Ohm.JsCode.t] ;
  icon   : string ;
  text   : Ohm.I18n.text
> 

val component :
     text:Ohm.I18n.text 
  -> actions:item list
  -> i18n:Ohm.I18n.t
  -> Ohm.View.Context.box Ohm.View.t
