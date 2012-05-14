(* © 2012 RunOrg *)

val box :
     user:[< `Admin | `Safe] ICurrentUser.id
  -> i18n:Ohm.I18n.t
  -> 'a O.box
