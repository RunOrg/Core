(* © 2012 RunOrg *)

val get : [<`IsSelf|`IsAdmin] IMembership.id -> (string * Json_type.t) list O.run

val restore_update : 
     IGroup.t
  -> IAvatar.t
  -> (string * Json_type.t) list
  -> unit O.run

val self_update :
      'any IGroup.id
  -> [`IsSelf] IAvatar.id
  -> MUpdateInfo.t
  -> ?irreversible:string list
  -> (string * Json_type.t) list
  -> unit O.run

val admin_update :
     [`IsSelf] IAvatar.id
  -> [<`Write|`Admin|`Bot] IGroup.id
  -> 'any IAvatar.id
  -> MUpdateInfo.t
  -> (string * Json_type.t) list
  -> unit O.run

val count :
     [<`Admin|`Write|`List] IGroup.id
  -> string
  -> (Json_type.t * int) list O.run

val obliterate : IMembership.t -> unit O.run
