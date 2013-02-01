(* © 2013 RunOrg *)

module View : sig

  module Count : sig
    type t = < old_count : int ; new_count : int ; read : int option ; unread : int option >
  end 

  type t = <
    owner  : IInboxLineOwner.t ;
    wall   : Count.t ;
    folder : Count.t ;
    album  : Count.t ; 
    time   : float ;
    seen   : bool ;
    aid    : IAvatar.t ;
    filter : IInboxLine.Filter.t list ; 
  >

  val filters : 'any MActor.t -> (#O.ctx, (IInboxLine.Filter.t * int) list) Ohm.Run.t

  val list : 
       ?start:float
    -> ?filter:IInboxLine.Filter.t
    -> count:int
    -> 'any MActor.t
    -> (t -> ((#O.ctx as 'ctx),'a option) Ohm.Run.t)
    -> ('ctx,'a list * float option) Ohm.Run.t  

  val mark : 'a MActor.t -> 'b IInboxLineOwner.id -> (#O.ctx,unit) Ohm.Run.t

end
