(* © 2013 RunOrg *)

module Data : sig
  type t = {
    directory : MAccess.t ;
    events    : MAccess.t ;
    freeze    : bool 
  }
end

val get : 'any IInstance.id -> Data.t O.run

val set : [`IsAdmin] IInstance.id -> Data.t -> unit O.run

val update : [ `IsAdmin ] IInstance.id -> (Data.t -> Data.t) -> unit O.run

val view_directory : 'any IInstance.id -> [ `Admin | `Member ] O.run
val can_view_directory : 'any MActor.t -> [`ViewContacts] IInstance.id option O.run

val create_event : 'any IInstance.id -> [ `Admin | `Member ] O.run
val can_create_event : 'any MActor.t -> [`CreateEvent] IInstance.id option O.run 

val wall_post : 'any IInstance.id -> [> `Admin | `Member ] O.run
 
