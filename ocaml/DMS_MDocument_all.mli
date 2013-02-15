(* © 2013 RunOrg *)

type entry = < 
  doc     : [`Unknown] DMS_MDocument_can.t ; 
  name    : string ; 
  version : int ; 
  update  : float * IAvatar.t ;
>

val in_repository :
     ?actor:'any MActor.t
  -> ?start:float
  -> count:int
  -> [<`View|`Admin] DMS_IRepository.id 
  -> (#O.ctx, entry list * float option ) Ohm.Run.t
