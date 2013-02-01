(* © 2013 RunOrg *)

val reverse : [<`Rights|`Bot] IInstance.id -> MAccess.t list -> IAvatar.t list O.run 

val reverse_async :
     [<`Bot] IInstance.id
  -> ?start:IAvatar.t
  -> count:int
  -> MAccess.t list 
  -> (#O.ctx,IAvatar.t list * IAvatar.t option) Ohm.Run.t
