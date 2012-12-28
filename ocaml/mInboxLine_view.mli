(* © 2012 RunOrg *)

val update : 'a IInboxLine.id -> 'b IAvatar.id -> MInboxLine_common.Line.t -> (#O.ctx,unit) Ohm.Run.t

module Count : sig
  type t = < old_count : int ; new_count : int ; read : int option ; unread : int option >
end 
    
type t = <
  owner  : IInboxLineOwner.t ;
  wall   : Count.t ;
  folder : Count.t ;
  album  : Count.t ; 
  time   : float ;
  aid    : IAvatar.t ; 
  seen   : bool ;
>

val list : 
     ?start:float
  -> count:int
  -> 'any MActor.t
  -> (t -> ((#O.ctx as 'ctx),'a option) Ohm.Run.t)
  -> ('ctx,'a list * float option) Ohm.Run.t  
  
val mark : 'a MActor.t -> 'b IInboxLineOwner.id -> (#O.ctx,unit) Ohm.Run.t
