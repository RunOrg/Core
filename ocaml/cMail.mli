(* © 2013 RunOrg *)

module Wrap : sig

  val render :
       ?iid:IInstance.t
    -> IWhite.t option
    -> [`IsSelf] IUser.id
    -> Ohm.Html.writer O.run
    -> (string option * Ohm.Html.writer O.run) O.run

end

module Footer : sig

  val core : IMail.t -> [`IsSelf] IUser.id -> IWhite.t option -> VMailBrick.footer

  val instance : IMail.t -> [`IsSelf] IUser.id -> MInstance.t -> VMailBrick.footer

end

val link : IMail.t -> IMail.Action.t option -> IWhite.t option -> string
