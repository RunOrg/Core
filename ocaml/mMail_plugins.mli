(* © 2013 RunOrg *) 

module type PLUGIN = sig
  include Ohm.Fmt.FMT
  val id : IMail.Plugin.t
  val iid : t -> IInstance.t option 
  val uid : t -> IUser.t 
  val from : t -> IAvatar.t option     
  val solve : t -> IMail.Solve.t option 
end

module Register : functor(P:PLUGIN) -> sig

  type t = P.t

  val send_one : ?time:float -> ?mwid:IMail.Wave.t -> t -> (#O.ctx,unit) Ohm.Run.t
  val send_many : ?time:float -> ?mwid:IMail.Wave.t -> t list -> (#O.ctx,unit) Ohm.Run.t 
  val solve : IMail.Solve.t -> unit O.run 

  (* Define "rendering" function. Notifications for which this function 
     returns [None] will be considered dead and removed from the user's
     list. *)
  val define : (t MMail_types.stub -> MMail_types.render option O.run) -> unit

end 

val parse : IMail.t -> MMail_core.Data.t -> MMail_types.full option O.run 
