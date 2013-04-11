(* © 2013 RunOrg *)

class type ['level] t = object
  method actor            : 'level MActor.t
  method self             : [`IsSelf] IAvatar.id
  method instance         : MInstance.t
  method iid              : 'level IInstance.id 
end

val make : 
     [`Old] ICurrentUser.id
  -> 'any IInstance.id
  -> MInstance.t
  -> [`IsToken] t option O.run

val admin : 'any t -> [`IsAdmin] t option

val of_actor : 'level MActor.t -> 'level t option O.run

val of_notification : [`IsSelf] IUser.id -> 'any IInstance.id -> [`IsToken] t option O.run 
