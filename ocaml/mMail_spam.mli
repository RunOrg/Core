(* © 2013 RunOrg *) 

type attitude = 
  [ `Blocked 
  | `Bounced
  | `Allowed
  | `NewContact (* User is confirmed but did not allow the instance yet. *)
  | `Silent of int (* Unconfirmed user receiving unread e-mail *) 
  ]

val attitude : 'a IUser.id -> 'b IInstance.id -> (#O.ctx, attitude) Ohm.Run.t

val can_send : 'a IUser.id -> (#O.ctx, bool) Ohm.Run.t

val get : 'a IUser.id -> 'b IInstance.id -> (#O.ctx, bool option) Ohm.Run.t

val set : ?mid:IMail.t -> 'a IUser.id -> 'b IInstance.id -> bool -> (#O.ctx, unit) Ohm.Run.t

val bounce : 'a IUser.id -> (#O.ctx, unit) Ohm.Run.t
