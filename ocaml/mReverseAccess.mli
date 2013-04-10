(* © 2013 RunOrg *)

val inSet : ([`List] IAvatarSet.id * IAvatar.t option * int, (O.ctx, IAvatar.t list) Ohm.Run.t) Ohm.Sig.channel

val reverse :
     [<`Bot] IInstance.id
  -> ?start:IAvatar.t
  -> count:int
  -> MAccess.t list 
  -> (#O.ctx,IAvatar.t list * IAvatar.t option) Ohm.Run.t

val async : 
  (* Call at initialization time *)
     string
  -> 'a Ohm.Fmt.fmt
  -> ('a -> IAvatar.t -> unit O.run)
  -> ('a -> unit O.run) 
  (* Call to start processing *) 
  -> ([`Bot] IInstance.id -> MAccess.t list -> 'a -> unit O.run) 
