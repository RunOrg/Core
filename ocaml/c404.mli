(* © 2012 Runorg *)

val render : ?iid:IInstance.t -> ICurrentUser.t option -> Ohm.Action.response -> Ohm.Action.response O.run
