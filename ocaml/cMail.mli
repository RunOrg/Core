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

  val instance : [`IsSelf] IUser.id -> MInstance.t -> VMailBrick.footer

end
