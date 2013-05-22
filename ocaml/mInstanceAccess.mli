(* © 2013 RunOrg *)

module Data : sig
  type t = {
    events    : IDelegation.t ;
  }
end

val get    : 'any IInstance.id -> (#O.ctx,Data.t) Ohm.Run.t
val update : [`IsAdmin] IInstance.id -> (Data.t -> Data.t) -> unit O.run

val can_create_event : 'any MActor.t -> [`CreateEvent] IInstance.id option O.run 
