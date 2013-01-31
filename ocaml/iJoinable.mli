(* © 2013 RunOrg *)

type t = [ `Group of IGroup.t
	 | `Event of IEvent.t ]

val arg : t Ohm.Action.Args.cell
