(* © 2012 RunOrg *)

type 'relation t 

val make : 'a IEvent.id -> ?access:'any # MAccess.context -> MEvent_core.t -> 'a t

val id   : 'any t -> 'any IEvent.id
val data : 'any t -> MEvent_core.t 

val view  : 'any t -> (#O.ctx,[`View]  t option) Ohm.Run.t
val admin : 'any t -> (#O.ctx,[`Admin] t option) Ohm.Run.t
