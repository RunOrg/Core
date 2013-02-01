(* © 2013 RunOrg *)

val inSet : ([`List] IAvatarSet.id * IAvatar.t option * int, (O.ctx, IAvatar.t list) Ohm.Run.t) Ohm.Sig.channel

val reverse :
     [<`Bot] IInstance.id
  -> ?start:IAvatar.t
  -> count:int
  -> MAccess.t list 
  -> (#O.ctx,IAvatar.t list * IAvatar.t option) Ohm.Run.t
