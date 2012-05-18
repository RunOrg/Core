(* © 2012 RunOrg *)

module Wrap : sig

  val render :
       ?iid:'a IInstance.id
    -> [`IsSelf] IUser.id
    -> Ohm.Html.writer O.run
    -> (string option * Ohm.Html.writer O.run) O.run

end

