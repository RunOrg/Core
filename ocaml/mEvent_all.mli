(* © 2012 RunOrg *)

val future :    
     ?access:'any # MAccess.context
  -> 'a IInstance.id 
  -> (#O.ctx,[`View] MEvent_can.t list) Ohm.Run.t  

val undated : 
     access:'any # MAccess.context
  -> 'a IInstance.id
  -> (#O.ctx,[`View] MEvent_can.t list) Ohm.Run.t

val past : 
     ?access:'any # MAccess.context
  -> ?start:(Date.t * IEvent.t) 
  -> count:int
  -> 'a IInstance.id
  -> (#O.ctx,[`View] MEvent_can.t list * (Date.t * IEvent.t) option) Ohm.Run.t
