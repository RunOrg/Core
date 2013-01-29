(* © 2013 RunOrg *)

(* Primary properties *)
val id       :            'any MGroup_can.t ->'any IGroup.id
val vision   : [<`Admin|`View] MGroup_can.t -> MGroup_vision.t
val name     : [<`Admin|`View] MGroup_can.t -> TextOrAdlib.t option 
val group    :            'any MGroup_can.t -> IAvatarSet.t 
val iid      :            'any MGroup_can.t -> IInstance.t 
val template : [<`Admin|`View] MGroup_can.t -> ITemplate.Group.t
val admins   : [<`Admin|`View] MGroup_can.t -> IAvatar.t list 
  
(* Helper properties *)
val public   : [<`Admin|`View] MGroup_can.t -> bool 
val status   : [<`Admin|`View] MGroup_can.t -> [ `Website | `Secret ] option 
val fullname : [<`Admin|`View] MGroup_can.t -> (#O.ctx,string) Ohm.Run.t

val is_admin :            'any MGroup_can.t -> (#O.ctx,bool) Ohm.Run.t
val is_all_members :      'any MGroup_can.t -> (#O.ctx,bool) Ohm.Run.t
