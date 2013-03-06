(* © 2013 RunOrg *)

include HEntity.SET with type 'a can = 'a DMS_MRepository_can.t and type diff = DMS_MRepository_core.diff
    
val admins : IAvatar.t list -> ('a,#O.ctx) t
val uploaders : IAvatar.t list -> ('a,#O.ctx) t

val info : 
     name:string
  -> vision:DMS_MRepository_vision.t
  -> upload:[`Viewers|`List]
  -> ('a,#O.ctx) t
  
val advanced : 
     detail:DMS_MRepository_detail.t
  -> remove:DMS_MRepository_remove.t
  -> ('a,#O.ctx) t
