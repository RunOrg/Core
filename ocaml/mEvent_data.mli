(* © 2012 RunOrg *)

type 'relation t

val get : 'id IEvent.id -> (#O.ctx,'id t option) Ohm.Run.t 
  
val update :
     'id IEvent.id
  -> [`IsSelf] IAvatar.id
  -> address:string option
  -> page:MRich.OrText.t
  -> (#O.ctx,unit) Ohm.Run.t

val address  : [<`Admin|`View] t -> string option
val page     : [<`Admin|`View] t -> MRich.OrText.t

