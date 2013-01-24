(* © 2013 RunOrg *)

include HEntity.SET with type 'a can = 'a MGroup_can.t and type diff = MGroup_core.diff
    
val admins : IAvatar.t list -> ('a,#O.ctx) t

val info : 
     name:TextOrAdlib.t option 
  -> vision:MGroup_vision.t
  -> ('a,#O.ctx) t
  

