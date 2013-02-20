(* © 2013 RunOrg *)

include HEntity.SET with type 'a can = 'a DMS_MDocument_can.t 
		    and  type diff = DMS_MDocument_core.diff
		    and  type 'a id = 'a DMS_IDocument.id 

val name : string -> ('a,#O.ctx) t
val share : [`Upload] DMS_IRepository.id -> ('a,#O.ctx) t
val unshare : [`Remove] DMS_IRepository.id -> ('a,#O.ctx) t

