(* © 2012 RunOrg *)

val future :    
     ?actor:'any MActor.t
  -> 'a IInstance.id 
  -> (#O.ctx,[`View] MEvent_can.t list) Ohm.Run.t  

val undated : 
     actor:'any MActor.t
  -> 'a IInstance.id
  -> (#O.ctx,[`View] MEvent_can.t list) Ohm.Run.t

val past : 
     ?actor:'any MActor.t
  -> ?start:(Date.t * IEvent.t) 
  -> count:int
  -> 'a IInstance.id
  -> (#O.ctx,[`View] MEvent_can.t list * (Date.t * IEvent.t) option) Ohm.Run.t
