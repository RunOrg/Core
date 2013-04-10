(* © 2013 RunOrg *) 

module Send : sig 

  val send :
       'a IUser.id 
    -> (    [ `IsSelf ] IUser.id
         -> MUser.t
         -> (    owid:IWhite.t option
  	      -> ?from:string
              -> subject:string 
              -> ?text:string
              -> html:Ohm.Html.writer 
              -> unit
              -> unit O.run )
         -> unit O.run )
     -> unit O.run

  val other_send_to_self :
       'a IUser.id 
    -> (    [ `IsSelf ] IUser.id
         -> MUser.t
         -> (    owid:IWhite.t option
  	      -> from:string option 
              -> subject:string O.run
              -> html:Ohm.Html.writer O.run
              -> unit O.run )
         -> unit O.run )
    -> bool O.run

end

module Types : sig

  type render_mail = 
    [`IsSelf] IUser.id -> MUser.t -> (string * string * Ohm.Html.writer) O.run 
      
  type act = 
      IMail.Action.t option -> string O.run 
      
  type render_item = 
      Ohm.Html.writer O.run 

  type info = <
    id      : IMail.t ; 
    wid     : IMail.Wave.t ; 
    plugin  : IMail.Plugin.t ; 
    iid     : IInstance.t option ;
    uid     : IUser.t ;
    from    : IAvatar.t option ; 
    time    : Date.t ;     
    zapped  : Date.t option ; (* Has the e-mail been marked as "read" from the site ? *) 
    opened  : Date.t option ; (* Has the sent e-mail been opened ? When ? *) 
    clicked : Date.t option ; (* Has any action been performed through this mail ? *)
    sent    : Date.t option ; (* Has this e-mail been actually sent ? *) 
    blocked : bool ; (* Has a processing rule prevented this e-mail from being sent ? *) 
    solved  : [ `Solved of Date.t (* This mail has been solved at the specified time. *)
	      | `NotSolved of IMail.Solve.t (* This e-mail can be solved through this id *)
	      ] option ;
    accept  : bool option ; (* Has the user agreed or declined to receive more 
			       from this particular sender as a consequence of THIS 
			       mail ? *)
  >

  type mail = <
    info    : info ;
    mail    : render_mail ;
    act     : act ; 
  > ;;

  type item = <
    info    : info ;
    item    : render_item ;
    act     : act ;
  > ;;

  type render = <
    act  : act ;
    mail : render_mail ;
    item : render_item option ;
  > ;;

end

module type PLUGIN = sig
    
  include Ohm.Fmt.FMT

  val id : IMail.Plugin.t

  val iid : t -> IInstance.t option 
  val uid : t -> IUser.t 
  val from : t -> IAvatar.t option 
    
  (* Is an action expected for this action ? How to identify it ? *)
  val solve : t -> IMail.Solve.t option 

  (* Is this mail an "item" expected to show up in the notification list ? *)
  val item : t -> bool 

end

module Register : functor(P:PLUGIN) -> sig

  type t = P.t

  val send_one  : ?time:float -> ?mwid:IMail.Wave.t -> t -> (#O.ctx,unit) Ohm.Run.t
  val send_many : ?time:float -> ?mwid:IMail.Wave.t -> t list -> (#O.ctx,unit) Ohm.Run.t 
  val solve : IMail.Solve.t -> unit O.run 

  (* Define "rendering" function. Notifications for which this function 
     returns [None] will be considered dead and removed from the user's
     list. *)
  val define : (t -> Types.info -> Types.render option O.run) -> unit

end 

module All : sig

  val mine : 
       ?start:Date.t
    -> count:int 
    -> 'any ICurrentUser.id 
    -> (#O.ctx, Types.item list * Date.t option) Ohm.Run.t

  val unread : 'any ICurrentUser.id -> (#O.ctx,int) Ohm.Run.t

end 

val zap_unread : 'any ICurrentUser.id -> unit O.run 

val get_token : IMail.t -> string

(* Counts as a click on an e-mail link *)
val from_token : 
     IMail.t 
  -> ?current:[`Old] ICurrentUser.id
  -> string
  -> (#O.ctx, [ `Valid   of Types.mail * [`Old] ICurrentUser.id
	      | `Expired of IUser.t
	      | `Missing 
	      ]) Ohm.Run.t

(* Counts as a click on a site link *)
val from_user : IMail.t -> 'any ICurrentUser.id -> (#O.ctx, Types.item option) Ohm.Run.t 

