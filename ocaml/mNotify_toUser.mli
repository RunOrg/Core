(* © 2012 RunOrg *)

type freq = [ `Immediate | `Daily | `Weekly | `Never ]

type assoc = (MNotifyChannel.t * freq) list
    
type t = <
  default : assoc ; 
  by_iid  : (IInstance.t * assoc) list 
> 

val set : [<`Edit|`Bot] IUser.id -> t -> unit O.run 
val get : [<`IsSelf|`Bot] IUser.id -> t O.run 
  
val default : MNotifyChannel.t -> freq 

val frequency : MNotifyChannel.t -> assoc -> freq

val send : IUser.t -> MNotify_payload.t -> freq O.run
