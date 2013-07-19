(* © 2013 RunOrg *)

(* Basic information *)
val id       : 'any DMS_MDocTask_can.t -> 'any DMS_IDocTask.id
val iid      : 'any DMS_MDocTask_can.t -> IInstance.t
val process  : 'any DMS_MDocTask_can.t -> PreConfig_Task.ProcessId.DMS.t
val state    : 'any DMS_MDocTask_can.t -> Ohm.Json.t
val data     : 'any DMS_MDocTask_can.t -> (string, Ohm.Json.t) BatMap.t
val assignee : 'any DMS_MDocTask_can.t -> IAvatar.t option 
val notified : 'any DMS_MDocTask_can.t -> IAvatar.t list
val created  : 'any DMS_MDocTask_can.t -> IAvatar.t * float
val updated  : 'any DMS_MDocTask_can.t -> IAvatar.t * float 

(* Helper functions *)
val theState : 'any DMS_MDocTask_can.t -> Ohm.Json.t * IAvatar.t * float
val finished : 'any DMS_MDocTask_can.t -> bool 
val fields   : 'any DMS_MDocTask_can.t -> (string * < label : O.i18n ; kind : DMS_MDocTask_fieldType.t >) list
val states   : 'any DMS_MDocTask_can.t -> (Ohm.Json.t * O.i18n) list 
val label    : 'any DMS_MDocTask_can.t -> O.i18n
