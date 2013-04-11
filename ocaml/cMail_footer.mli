(* © 2013 RunOrg *)

val core : IMail.t -> [`IsSelf] IUser.id -> IWhite.t option -> VMailBrick.footer

val instance : IMail.t -> [`IsSelf] IUser.id -> MInstance.t -> VMailBrick.footer
