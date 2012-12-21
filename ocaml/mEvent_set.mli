(* © 2012 RunOrg *)

val update : 
     [`Admin] MEvent_can.t
  -> [`IsSelf] IAvatar.id
  -> MEvent_core.Cfg.Diff.t list
  -> (#O.ctx,unit) Ohm.Run.t 
    
val picture :
     [`Admin] MEvent_can.t 
  -> [`IsSelf] IAvatar.id
  -> [`InsPic] IFile.id option
  -> (#O.ctx,unit) Ohm.Run.t
  
val admins : 
     [`Admin] MEvent_can.t
  -> [`IsSelf] IAvatar.id
  -> IAvatar.t list
  -> (#O.ctx,unit) Ohm.Run.t

val info : 
     [`Admin] MEvent_can.t
  -> [`IsSelf] IAvatar.id
  -> draft:bool 
  -> name:string option 
  -> page:MRich.OrText.t
  -> date:Date.t option
  -> address:string option 
  -> vision:MEvent_vision.t
  -> (#O.ctx,unit) Ohm.Run.t 
  
