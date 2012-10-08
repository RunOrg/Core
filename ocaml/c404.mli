(* © 2012 Runorg *)

val render : ?iid:IInstance.t -> IWhite.t option -> ICurrentUser.t option -> Ohm.Action.response -> Ohm.Action.response O.run
