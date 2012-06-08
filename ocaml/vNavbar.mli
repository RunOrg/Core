(* © 2012 RunOrg *)

type t = ICurrentUser.t option * IInstance.t option 

val intranet : t -> Ohm.Html.writer O.run 

val event : t -> Ohm.Html.writer O.run

val public :
     [>`Home|`Calendar|`About] 
  -> left:Ohm.Html.writer O.run
  -> main:Ohm.Html.writer O.run 
  -> cuid:ICurrentUser.t option
  -> MInstance.t
  -> Ohm.Html.writer O.run
