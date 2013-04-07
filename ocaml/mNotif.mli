(* © 2013 RunOrg *) 

module Types : sig

  type full = <
    (* From stub *)
    id      : INotif.t ; 
    mid     : IMailing.t ; 
    plugin  : INotif.Plugin.t ; 
    iid     : IInstance.t option ;
    uid     : IUser.t ;
    from    : IAvatar.t option ; 
    time    : float ; 
    read    : float option ;
    sent    : float option ; 
    solved  : float option ; (* Equal to "read" date if does not require solving *)
    nmc     : int ;
    nsc     : int ; 
    nzc     : int ; 
    (* From render *) 
    mail    : MUser.t -> (string * string * Ohm.Html.writer) O.run ; 
    list    : Ohm.Html.writer O.run ; 
    act     : INotif.Action.t option -> string O.run ;
  > ;;

  type render = <
    mail : MUser.t -> (string * string * Ohm.Html.writer) O.run ; 
    list : Ohm.Html.writer O.run ;
    act  : INotif.Action.t option -> string O.run ; 
  > ;;

end

module type PLUGIN = sig
    
  include Ohm.Fmt.FMT

  val id : INotif.Plugin.t

  val iid : t -> IInstance.t option 
  val uid : t -> IUser.t 
  val from : t -> IAvatar.t option 
    
  (* Is an action expected for this action ? How to identify it ? *)
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
  val define : (t -> Types.render option O.run) -> unit

end 

module All : sig

  val mine : 
       ?start:float
    -> count:int 
    -> 'any ICurrentUser.id 
    -> (#O.ctx, Types.full list * float option) Ohm.Run.t

  val unread : 'any ICurrentUser.id -> (#O.ctx,int) Ohm.Run.t

end 

val send : (Types.full -> (#O.ctx as 'ctx, unit) Ohm.Run.t) -> ('ctx,bool) Ohm.Run.t

val zap_unread : 'any ICurrentUser.id -> unit O.run 

val get_token : INotif.t -> string

(* Counts as a click on an e-mail link *)
val from_token : 
     INotif.t 
  -> ?current:[`Old] ICurrentUser.id
  -> string
  -> (#O.ctx, [ `Valid   of Types.full * [`Old] ICurrentUser.id
	      | `Expired of IUser.t
	      | `Missing 
	      ]) Ohm.Run.t

(* Counts as a click on a site link *)
val from_user : INotif.t -> 'any ICurrentUser.id -> (#O.ctx, Types.full option) Ohm.Run.t 
