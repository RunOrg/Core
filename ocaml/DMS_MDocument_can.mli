(* © 2013 RunOrg *)

include HEntity.CAN with type core = DMS_MDocument_core.t and type 'a id = 'a DMS_IDocument.id

val download : 'a t -> (#O.ctx,bool) Ohm.Run.t
