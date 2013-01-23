(* © 2012 RunOrg *)

(* Primary properties *)
val id       :            'any MEvent_can.t ->'any IEvent.id
val draft    : [<`Admin|`View] MEvent_can.t -> bool
val vision   : [<`Admin|`View] MEvent_can.t -> MEvent_vision.t
val name     : [<`Admin|`View] MEvent_can.t -> string option 
val picture  : [<`Admin|`View] MEvent_can.t -> [`GetPic] IFile.id option 
val date     : [<`Admin|`View] MEvent_can.t -> Date.t option
val group    :            'any MEvent_can.t -> IAvatarSet.t 
val iid      :            'any MEvent_can.t -> IInstance.t 
val template : [<`Admin|`View] MEvent_can.t -> ITemplate.Event.t
val admins   : [<`Admin|`View] MEvent_can.t -> IAvatar.t list 
  
(* Helper properties *)
val public   : [<`Admin|`View] MEvent_can.t -> bool 
val status   : [<`Admin|`View] MEvent_can.t -> [ `Draft | `Website | `Secret ] option 
val data     :            'any MEvent_can.t -> (#O.ctx,'any MEvent_data.t option) Ohm.Run.t
val fullname : [<`Admin|`View] MEvent_can.t -> (#O.ctx,string) Ohm.Run.t
