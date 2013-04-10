(* © 2013 RunOrg *) 

val mine : 
     ?start:Date.t
  -> count:int 
  -> 'any ICurrentUser.id 
  -> (#O.ctx, MMail_types.item list * Date.t option) Ohm.Run.t
  
val unread : 'any ICurrentUser.id -> (#O.ctx,int) Ohm.Run.t
