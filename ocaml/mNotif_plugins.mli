(* © 2013 RunOrg *) 

module type PLUGIN = sig
  include Ohm.Fmt.FMT
  val id : INotif.Plugin.t
  val iid : t -> IInstance.t option 
  val uid : t -> IUser.t 
  val from : t -> IAvatar.t option     
  val solve : t -> INotif.Solve.t option 
end

module Register : functor(P:PLUGIN) -> sig

  type t = P.t

  val send_one : ?mid:IMailing.t -> t -> (#O.ctx,unit) Ohm.Run.t
  val send_many : ?mid:IMailing.t -> t list -> (#O.ctx,unit) Ohm.Run.t 
  val solve : INotif.Solve.t -> unit O.run 

  (* Define "rendering" function. Notifications for which this function 
     returns [None] will be considered dead and removed from the user's
     list. *)
  val define : (t -> MNotif_types.render option O.run) -> unit

end 

val parse : INotif.t -> MNotif_core.Data.t -> MNotif_types.full option O.run 
