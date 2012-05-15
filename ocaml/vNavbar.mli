(* © 2012 RunOrg *)

type t = [`View] IUser.id option * IInstance.t option 

val render : t -> Ohm.Html.writer O.run 
