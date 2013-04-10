(* © 2013 RunOrg *) 

val mine : 
     ?start:float
  -> count:int 
  -> 'any ICurrentUser.id 
  -> (#O.ctx, MMail_types.full list * float option) Ohm.Run.t
  
val unread : 'any ICurrentUser.id -> (#O.ctx,int) Ohm.Run.t
