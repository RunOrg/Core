(* © 2012 RunOrg *)

include HEntity.CAN with type core = MEvent_core.t and type 'a id = 'a IEvent.id

val member_access : 'any t -> MAccess.t list 
