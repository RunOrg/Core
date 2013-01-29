(* © 2012 RunOrg *)

include HEntity.SET with type 'a can = 'a MEvent_can.t and type diff = MEvent_core.diff
    
val picture : [`InsPic] IFile.id option -> ('a,#O.ctx) t
  
val admins : IAvatar.t list -> ('a,#O.ctx) t

val info : 
     draft:bool 
  -> name:string option 
  -> page:MRich.OrText.t
  -> date:Date.t option
  -> address:string option 
  -> vision:MEvent_vision.t
  -> ('a,#O.ctx) t
  

