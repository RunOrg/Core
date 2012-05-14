(* © 2012 RunOrg *)

open Ohm
open UrlClientHelper
open UrlR
  
let order_start = object (self)
  inherit rest "pay/order"
  method build : 'a 'b.< instance : MInstance.t ; myself : 'a IIsIn.id ; .. > as 'b -> [`Edit] IRunOrg.Order.id -> string =
    fun ctx order ->
      self # rest (ctx # instance)
	[ IRunOrg.Order.to_string order ;
	  IRunOrg.Order.Deduce.make_edit_token
	    (IIsIn.user (ctx # myself))
	    (IInstance.decay (IIsIn.instance (ctx # myself)))
	    order
	]
end 

let ok = object (self) 
  inherit rest "pay/ok"
  method build instance (id : IPayment.t) = 
    self # rest instance [ IPayment.to_string id ]
end

let exec = object (self) 
  inherit rest "pay/exec"
  method build instance cuid (id : [`Exec] IPayment.id) = 
    self # rest instance [ IPayment.to_string id ;
			   IPayment.Deduce.make_exec_token cuid id ]
end
