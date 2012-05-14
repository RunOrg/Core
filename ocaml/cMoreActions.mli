(* © 2012 RunOrg *)

val make : Ohm.I18n.text * string * [ `Go of string | `Do of Ohm.JsCode.t ] 
  -> VMoreActions.item
