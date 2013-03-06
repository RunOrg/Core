(* © 2013 RunOrg *)

type t = IWhite.t option * ICurrentUser.t option * IInstance.t option 

val intranet : t -> Ohm.Html.writer O.run 

val event : t -> Ohm.Html.writer O.run

val public :
     [>`Home|`Calendar|`About|`Join] 
  -> left:Ohm.Html.writer O.run
  -> main:Ohm.Html.writer O.run 
  -> cuid:ICurrentUser.t option
  -> MInstance.t
  -> Ohm.Html.writer O.run

val registerPlugin : IPlugin.t -> (IWhite.key,string list) Ohm.Action.endpoint -> O.i18n -> unit
