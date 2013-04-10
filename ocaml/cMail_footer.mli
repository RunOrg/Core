(* © 2013 RunOrg *)

val core : [`IsSelf] IUser.id -> IWhite.t option -> VMailBrick.footer

val instance : [`IsSelf] IUser.id -> MInstance.t -> VMailBrick.footer
