(* © 2013 RunOrg *)

include HEntity.SET with type 'a can = 'a DMS_MRepository_can.t and type diff = DMS_MRepository_core.diff
    
val admins : IAvatar.t list -> ('a,#O.ctx) t

val info : 
     name:string
  -> vision:DMS_MRepository_vision.t
  -> ('a,#O.ctx) t
  

