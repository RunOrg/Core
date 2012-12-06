(* © 2012 RunOrg *)

type 'relation t 

module Vision : Ohm.Fmt.FMT with type t = [ `Website | `Normal | `Secret ]

module Can : sig
  val view  : 'any t -> (#O.ctx,[`View]  t option) Ohm.Run.t 
  val admin : 'any t -> (#O.ctx,[`Admin] t option) Ohm.Run.t 
end

module Data : sig

  type 'relation t

  val address  : [<`Admin|`View] t -> string option
  val page     : [<`Admin|`View] t -> MRich.OrText.t

end

module Get : sig

  (* Primary properties *)
  val id       :            'any t ->'any IEvent.id
  val draft    : [<`Admin|`View] t -> bool
  val vision   : [<`Admin|`View] t -> Vision.t
  val name     : [<`Admin|`View] t -> string option 
  val picture  : [<`Admin|`View] t -> [`GetPic] IFile.id option 
  val date     : [<`Admin|`View] t -> Date.t option
  val group    :            'any t -> IGroup.t 
  val iid      :            'any t -> IInstance.t 
  val template : [<`Admin|`View] t -> ITemplate.Event.t
  val admins   : [<`Admin|`View] t -> IAvatar.t list 

  (* Helper properties *)
  val public   : [<`Admin|`View] t -> bool 
  val status   : [<`Admin|`View] t -> [ `Draft | `Website | `Secret ] option 
  val data     :            'any t -> (#O.ctx,'any Data.t option) Ohm.Run.t

end

val create : 
     self:[`IsSelf] IAvatar.id
  -> name:string option
  -> ?pic:[`InsPic] IFile.id
  -> ?vision:Vision.t 
  -> iid:[`CreateEvent] IInstance.id
  -> ITemplate.Event.t
  -> (#O.ctx,IEntity.t) Ohm.Run.t 

module Set : sig
    
  val picture :
       [`Admin] t 
    -> [`IsSelf] IAvatar.id
    -> [`InsPic] IFile.id option
    -> (#O.ctx,unit) Ohm.Run.t

  val admins : 
       [`Admin] t
    -> [`IsSelf] IAvatar.id
    -> IAvatar.t list
    -> (#O.ctx,unit) Ohm.Run.t

  val info : 
       [`Admin] t
    -> [`IsSelf] t
    -> draft:bool 
    -> name:string option 
    -> page:MRich.OrText.t
    -> address:string option 
    -> vision:Vision.t
    -> (#O.ctx,unit) Ohm.Run.t 

end

module All : sig

  val future :    
       ?access:'any # MAccess.context
    -> 'a IInstance.id 
    -> (#O.ctx,[`View] t list) Ohm.Run.t  

  val undated : 
       access:'any # MAccess.context
    -> 'a IInstance.id
    -> (#O.ctx,[`View] t list) Ohm.Run.t

  val past : 
       ?access:'any # MAccess.context
    -> ?start:Date.t
    -> count:int
    -> 'a IInstance.id
    -> (#O.ctx,[`View] t list * Date.t option) Ohm.Run.t

end

val get : ?access:'any # MAccess.context -> 'rel IEvent.id -> (#O.ctx,'rel t option) Ohm.Run.t
 
val delete : [`Admin] t -> [`IsSelf] IAvatar.id -> (#O.ctx,unit) Ohm.Run.t 
