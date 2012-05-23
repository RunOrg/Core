(* © 2012 RunOrg *)

type t = ICurrentUser.t option * IInstance.t option 

val render : t -> Ohm.Html.writer O.run 
