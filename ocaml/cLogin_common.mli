(* © 2012 RunOrg *)

val mail_i18n : Ohm.I18n.t

val with_self : 
     proof:string option
  -> uid:string option
  -> fail:O.Action.response O.run
  -> ([`IsSelf] IUser.id -> O.Action.response O.run)
  -> O.Action.response O.run
