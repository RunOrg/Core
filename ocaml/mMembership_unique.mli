(* © 2012 RunOrg *)

val find           : 'g IGroup.id -> 'a IAvatar.id -> IMembership.t O.run
val find_if_exists : 'g IGroup.id -> 'a IAvatar.id -> IMembership.t option O.run
val obliterate     : 'g IGroup.id -> 'a IAvatar.id -> unit O.run
