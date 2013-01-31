(* © 2013 RunOrg *)

val visible :    
     ?actor:'any MActor.t
  -> 'a IInstance.id 
  -> (#O.ctx,[`View] MGroup_can.t list) Ohm.Run.t  

