(* © 2012 RunOrg *) 

val get           : 'any IUser.id -> IDigest.t O.run
val get_if_exists : 'any IUser.id -> IDigest.t option O.run
val reverse       : IDigest.t -> IUser.t list O.run
