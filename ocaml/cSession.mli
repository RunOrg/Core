(* © 2012 RunOrg *)

val start : [ `Old of [`Old] ICurrentUser.id 
	    | `New of [`New] ICurrentUser.id ] -> Ohm.Action.response -> Ohm.Action.response
val check : ('a,'b) Ohm.Action.request -> [ `None 
					  | `Old of [`Old] ICurrentUser.id 
					  | `New of [`New] ICurrentUser.id ]
val close : Ohm.Action.response -> Ohm.Action.response
