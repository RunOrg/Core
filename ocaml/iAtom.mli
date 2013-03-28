(* © 2013 RunOrg *)

module Nature : sig
  include Ohm.Fmt.FMT with type t = PreConfig_Atom.Id.t
  val arg : t Ohm.Action.Args.cell
  val can_create : t -> bool
  val parents : t -> t list 
end
  
include Ohm.Id.PHANTOM
