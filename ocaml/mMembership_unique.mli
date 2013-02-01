(* © 2013 RunOrg *)

val find           : 'g IAvatarSet.id -> 'a IAvatar.id -> IMembership.t O.run
val find_if_exists : 'g IAvatarSet.id -> 'a IAvatar.id -> IMembership.t option O.run
val obliterate     : 'g IAvatarSet.id -> 'a IAvatar.id -> unit O.run
