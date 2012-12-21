(* © 2012 RunOrg *)

type t = [ `Entity of IEntity.t
	 | `Event  of IEvent.t ]

val arg : t Ohm.Action.Args.cell
