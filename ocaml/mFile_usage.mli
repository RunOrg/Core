(* © 2012 RunOrg *)

val user : [`IsSelf] IUser.id -> (float * float) O.run
val instance : [`SeeUsage] IInstance.id -> (float * float) O.run
