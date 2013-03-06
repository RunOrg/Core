(* © 2013 RunOrg *)

val visible : 
     ?actor:'any MActor.t
  -> ?start:DMS_IRepository.t
  -> count:int
  -> 'a IInstance.id
  -> (#O.ctx,[`View] DMS_MRepository_can.t list * DMS_IRepository.t option) Ohm.Run.t
