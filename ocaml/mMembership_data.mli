(* © 2012 RunOrg *)

val get : [<`IsSelf|`IsAdmin] IMembership.id -> (string * Ohm.Json.t) list O.run

val restore_update : 
     IGroup.t
  -> IAvatar.t
  -> (string * Ohm.Json.t) list
  -> unit O.run

val self_update :
     'any IGroup.id
  -> 'b MActor.t
  -> MUpdateInfo.t
  -> ?irreversible:string list
  -> (string * Ohm.Json.t) list
  -> unit O.run

val admin_update :
     'a MActor.t
  -> [<`Write|`Admin|`Bot] IGroup.id
  -> 'any IAvatar.id
  -> MUpdateInfo.t
  -> (string * Ohm.Json.t) list
  -> unit O.run

val count :
     [<`Admin|`Write|`List] IGroup.id
  -> string
  -> (Ohm.Json.t * int) list O.run

val obliterate : IMembership.t -> unit O.run
