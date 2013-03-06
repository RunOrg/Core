(* © 2013 RunOrg *)

include HEntity.CAN with type core = MGroup_core.t and type 'a id = 'a IGroup.id

val member_access : 'any t -> (#O.ctx,MAccess.t list) Ohm.Run.t
