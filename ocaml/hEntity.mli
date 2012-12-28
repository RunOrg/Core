(* © 2012 RunOrg *)

module type CAN = sig 

  type core 
  type 'a id 

  type 'relation t
    
  val make : 'a id -> ?actor:'any MActor.t -> core -> 'a t option 

  val id   : 'any t -> 'any id
  val data : 'any t -> core
    
  val view_access   : 'any t -> MAccess.t list
  val admin_access  : 'any t -> MAccess.t list 
    
  val view  : 'any t -> (#O.ctx,[`View]  t option) Ohm.Run.t 
  val admin : 'any t -> (#O.ctx,[`Admin] t option) Ohm.Run.t 
    
end
