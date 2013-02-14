(* © 2013 RunOrg *)

include HEntity.CAN with type core = DMS_MRepository_core.t and type 'a id = 'a DMS_IRepository.id

val upload : 'any t -> (#O.ctx,[`Upload] id option) Ohm.Run.t
val remove : 'any t -> (#O.ctx,[`Remove] id option) Ohm.Run.t

val view_access    : 'any t -> (#O.ctx,MAccess.t list) Ohm.Run.t
val admin_access   : 'any t -> (#O.ctx,MAccess.t list) Ohm.Run.t
val details_access : 'any t -> (#O.ctx,MAccess.t list) Ohm.Run.t
 
