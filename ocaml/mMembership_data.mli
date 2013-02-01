(* © 2013 RunOrg *)

val get : [<`IsSelf|`IsAdmin] IMembership.id -> (string * Ohm.Json.t) list O.run

val restore_update : 
     IAvatarSet.t
  -> IAvatar.t
  -> (string * Ohm.Json.t) list
  -> unit O.run

val self_update :
     'any IAvatarSet.id
  -> 'b MActor.t
  -> MUpdateInfo.t
  -> ?irreversible:string list
  -> (string * Ohm.Json.t) list
  -> unit O.run

val admin_update :
     'a MActor.t
  -> [<`Write|`Admin|`Bot] IAvatarSet.id
  -> 'any IAvatar.id
  -> MUpdateInfo.t
  -> (string * Ohm.Json.t) list
  -> unit O.run

val count :
     [<`Admin|`Write|`List] IAvatarSet.id
  -> string
  -> (Ohm.Json.t * int) list O.run

val obliterate : IMembership.t -> unit O.run
