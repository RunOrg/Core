(* © 2013 RunOrg *)

include HEntity.CAN with type core = DMS_MRepository_core.t and type 'a id = 'a DMS_IRepository.id

val upload : 'any t -> (#O.ctx,[`Upload] id option) Ohm.Run.t
