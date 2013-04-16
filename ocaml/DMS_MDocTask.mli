(* © 2013 RunOrg *)

type 'relation t

type state = Ohm.Json.t
type process = PreConfig_Task.ProcessId.DMS.t  

module Field : sig
  type t = string
end

module FieldType : sig 
  type t = 
    [ `TextShort
    | `TextLong
    | `PickOne  of (string * O.i18n) list
    | `PickMany of (string * O.i18n) list
    | `Date
    ]
end 

module Notify : sig
  type t = <
    what : [ `NewState    of state
  	   | `SetAssigned of IAvatar.t (* Who is the new assignee ? *)
	   | `SetNotified ] ;
    uid  : IUser.t ;
    iid  : IInstance.t ;
    dtid : DMS_IDocTask.t ;
    did  : DMS_IDocument.t ; 
    from : IAvatar.t ;
  >
  val define : 
    ([`IsSelf] IUser.id -> MUser.t -> t -> MMail.Types.info -> MMail.Types.render option O.run) -> unit
end

module All : sig
  val by_document : [`View] DMS_IDocument.id -> (#O.ctx,[`View] DMS_IDocTask.id list) Ohm.Run.t
  val last : [`View] DMS_IDocument.id -> process -> (#O.ctx,[`View] DMS_IDocTask.id option) Ohm.Run.t
end

module Get : sig
  (* Basic information *)
  val id       :    'any t -> 'any DMS_IDocTask.id
  val iid      :    'any t -> IInstance.t
  val process  :    'any t -> process
  val state    : [`View] t -> state
  val data     : [`View] t -> (Field.t, Ohm.Json.t) BatPMap.t
  val assignee : [`View] t -> IAvatar.t option 
  val notified : [`View] t -> IAvatar.t list
  val created  : [`View] t -> IAvatar.t * float
  val updated  : [`View] t -> IAvatar.t * float 
  (* Helper functions *)
  val theState : [`View] t -> state * IAvatar.t * float
  val finished : [`View] t -> bool 
  val fields   :    'any t -> (Field.t * < label : O.i18n ; kind : FieldType.t >) list
  val states   :    'any t -> (state * O.i18n) list 
  val label    :    'any t -> O.i18n
end

module Set : sig
  val info : 
       ?state:state
    -> ?assignee:IAvatar.t option
    -> ?notified:IAvatar.t list
    -> ?data:(Field.t,Ohm.Json.t) BatPMap.t
    -> [`View] t
    -> 'any MActor.t 
    -> (#O.ctx,unit) Ohm.Run.t
end

val createIfMissing : 
     process:process
  -> actor:'any MActor.t
  -> [`View] DMS_IDocument.id 
  -> (#O.ctx, [`View] DMS_IDocTask.id) Ohm.Run.t

val get : 'relation DMS_IDocTask.id -> (#O.ctx,'relation t option) Ohm.Run.t

val getFromDocument : 'any DMS_IDocTask.id -> [`View] DMS_IDocument.id -> (#O.ctx,[`View] t option) Ohm.Run.t
