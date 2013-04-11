(* © 2013 RunOrg *)

module Footer : sig

  val core : IMail.t -> [`IsSelf] IUser.id -> IWhite.t option -> VMailBrick.footer

  val instance : IMail.t -> [`IsSelf] IUser.id -> MInstance.t -> VMailBrick.footer

end

val link : IMail.t -> IMail.Action.t option -> IWhite.t option -> string
