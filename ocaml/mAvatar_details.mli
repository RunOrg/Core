(* © 2013 RunOrg *)

type details = <
  name    : string option ;
  sort    : string option ;
  picture : [`GetPic] IFile.id option ;
  ins     : IInstance.t option ;
  who     : IUser.t option ;
  status  : MAvatar_status.t option ;
  role    : string option ;
>

val from : MAvatar_common.Data.t -> details

val details : 'any IAvatar.id -> details O.run

val get_user : 'any IAvatar.id -> IUser.t option O.run
val get_instance : 'any IAvatar.id -> IInstance.t option O.run 
