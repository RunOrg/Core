(* © 2013 RunOrg *)

module Wrap : sig

  val render :
       ?iid:IInstance.t
    -> IWhite.t option
    -> [`IsSelf] IUser.id
    -> Ohm.Html.writer O.run
    -> (string option * Ohm.Html.writer O.run) O.run

end

