(* © 2012 RunOrg *)

val invite : 
     ?time: float
  -> ?uid: IUser.t
  -> ?iid: IInstance.t
  -> IAvatar.t
  -> unit O.run

val get_latest_confirmed :
     count:int
  -> ?start:(float * IAvatar.t)
  -> [`IsAdmin] IInstance.id
  -> ((IAvatar.t * float) list * (float * IAvatar.t) option) O.run

val obliterate : IAvatar.t -> unit O.run
